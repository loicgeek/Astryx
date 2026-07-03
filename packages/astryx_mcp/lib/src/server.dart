import 'dart:convert';

import 'package:astryx_core/astryx_core.dart';

const _json = JsonEncoder.withIndent('  ');
String _pretty(Object? v) => _json.convert(v);

const String _protocolVersion = '2024-11-05';

/// The MCP tools, derived from the shared [astryxOps] — so the agent surface
/// and the CLI/manifest surface cannot diverge.
List<Map<String, Object?>> mcpTools() {
  return [
    for (final op in astryxOps)
      {
        'name': op.mcpTool,
        'description': op.summary,
        'inputSchema': {
          'type': 'object',
          'properties': {
            for (final a in op.args)
              a.name: {'type': 'string', if (a.doc.isNotEmpty) 'description': a.doc},
          },
          'required': [for (final a in op.args) if (a.required) a.name],
        },
      },
  ];
}

/// The MCP resources (nouns) the server exposes.
List<Map<String, Object?>> mcpResources() {
  return [
    {'uri': 'astryx://manifest', 'name': 'Astryx manifest', 'mimeType': 'application/json'},
    {'uri': 'astryx://registry', 'name': 'Component registry', 'mimeType': 'application/json'},
    {'uri': 'astryx://guidelines/a11y', 'name': 'Accessibility checklist', 'mimeType': 'text/markdown'},
    for (final c in astryxRegistry)
      {'uri': 'astryx://components/${c.name}', 'name': c.name, 'mimeType': 'application/json'},
  ];
}

const String a11yChecklist = '''
# Astryx accessibility checklist
- Correct Semantics role/flags; icon-only controls carry a label.
- Keyboard equivalent for every pointer action; visible keyboard-only focus ring.
- Announce async status via a live region.
- 48x48 minimum tap target; respect textScaler to 200%.
- Contrast >= 4.5:1 text / 3:1 on-accent (light and dark).
- Honor reduced motion (AstryxMotion.resolve).
- Never convey meaning by color alone.
''';

/// Handles one JSON-RPC request, returning the response map — or null for
/// notifications (which take no response). Pure and synchronous for testability.
Map<String, Object?>? handleMcp(Map<String, Object?> request) {
  final id = request['id'];
  final method = request['method'] as String?;
  final params = (request['params'] as Map?)?.cast<String, Object?>() ?? const {};

  // Notifications have no id and expect no response.
  if (id == null) return null;

  switch (method) {
    case 'initialize':
      return _ok(id, {
        'protocolVersion': _protocolVersion,
        'capabilities': {'tools': <String, Object?>{}, 'resources': <String, Object?>{}},
        'serverInfo': {'name': 'astryx-mcp', 'version': astryxToolVersion},
      });

    case 'ping':
      return _ok(id, <String, Object?>{});

    case 'tools/list':
      return _ok(id, {'tools': mcpTools()});

    case 'resources/list':
      return _ok(id, {'resources': mcpResources()});

    case 'tools/call':
      return _callTool(id, params);

    case 'resources/read':
      return _readResource(id, params);

    default:
      return _err(id, -32601, 'Method not found: $method');
  }
}

Map<String, Object?> _callTool(Object? id, Map<String, Object?> params) {
  final name = params['name'] as String?;
  final args = (params['arguments'] as Map?)?.cast<String, Object?>() ?? const {};

  String? text;
  switch (name) {
    case 'astryx_list_components':
      text = _pretty([
        for (final c in listComponents()) {'name': c.name, 'category': c.category, 'status': c.status.name},
      ]);
    case 'astryx_get_component':
      final c = findComponent('${args['name']}');
      if (c == null) return _toolError(id, 'Unknown component: ${args['name']}');
      text = _pretty(c.toJson());
    case 'astryx_get_template':
      final code = renderTemplate('${args['name']}');
      if (code == null) return _toolError(id, 'Unknown template: ${args['name']}');
      text = code;
    case 'astryx_theme':
      final n = args['name'];
      if (n == null || '$n'.isEmpty) {
        text = _pretty(astryxThemeNames);
      } else if (astryxThemeNames.contains('$n')) {
        text = _pretty({'theme': '$n', 'usage': "AstryxThemeCatalog.byName('$n')"});
      } else {
        return _toolError(id, 'Unknown theme: $n');
      }
    case 'astryx_swizzle_component':
      final plan = swizzlePlan('${args['name']}');
      if (plan == null) return _toolError(id, 'Unknown component: ${args['name']}');
      text = _pretty(plan);
    case 'astryx_manifest':
      text = _pretty(buildManifest());
    default:
      return _err(id, -32602, 'Unknown tool: $name');
  }

  return _ok(id, {
    'content': [
      {'type': 'text', 'text': text},
    ],
    'isError': false,
  });
}

Map<String, Object?> _readResource(Object? id, Map<String, Object?> params) {
  final uri = params['uri'] as String? ?? '';
  String? text;
  String mime = 'application/json';

  if (uri == 'astryx://manifest') {
    text = _pretty(buildManifest());
  } else if (uri == 'astryx://registry') {
    text = _pretty([for (final c in astryxRegistry) c.toJson()]);
  } else if (uri == 'astryx://guidelines/a11y') {
    text = a11yChecklist;
    mime = 'text/markdown';
  } else if (uri.startsWith('astryx://components/')) {
    final c = findComponent(uri.substring('astryx://components/'.length));
    if (c != null) text = _pretty(c.toJson());
  } else if (uri.startsWith('astryx://templates/')) {
    final code = renderTemplate(uri.substring('astryx://templates/'.length));
    if (code != null) {
      text = code;
      mime = 'text/plain';
    }
  }

  if (text == null) return _err(id, -32002, 'Resource not found: $uri');
  return _ok(id, {
    'contents': [
      {'uri': uri, 'mimeType': mime, 'text': text},
    ],
  });
}

Map<String, Object?> _toolError(Object? id, String message) => _ok(id, {
      'content': [
        {'type': 'text', 'text': message},
      ],
      'isError': true,
    });

Map<String, Object?> _ok(Object? id, Object? result) =>
    {'jsonrpc': '2.0', 'id': id, 'result': result};

Map<String, Object?> _err(Object? id, int code, String message) =>
    {'jsonrpc': '2.0', 'id': id, 'error': {'code': code, 'message': message}};
