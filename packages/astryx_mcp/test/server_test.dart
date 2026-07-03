import 'dart:convert';

import 'package:astryx_core/astryx_core.dart';
import 'package:astryx_mcp/src/server.dart';
import 'package:test/test.dart';

Map<String, Object?>? call(String method, [Map<String, Object?> params = const {}]) =>
    handleMcp({'jsonrpc': '2.0', 'id': 1, 'method': method, 'params': params});

Object? result(Map<String, Object?>? resp) => resp!['result'];

void main() {
  test('CONTRACT: MCP tools exactly match the manifest operations', () {
    final toolNames = mcpTools().map((t) => t['name']).toSet();
    final opToolNames = astryxOps.map((o) => o.mcpTool).toSet();
    final manifestToolNames = {
      for (final o in (buildManifest()['operations']! as List)) (o as Map)['mcpTool'],
    };
    expect(toolNames, opToolNames);
    expect(toolNames, manifestToolNames);
  });

  test('initialize returns protocol + server info', () {
    final r = result(call('initialize')) as Map;
    expect(r['protocolVersion'], isNotNull);
    expect((r['serverInfo']! as Map)['name'], 'astryx-mcp');
  });

  test('notifications (no id) get no response', () {
    expect(handleMcp({'jsonrpc': '2.0', 'method': 'notifications/initialized'}), isNull);
  });

  test('tools/call get_component returns the component JSON', () {
    final r = result(call('tools/call', {'name': 'astryx_get_component', 'arguments': {'name': 'Button'}})) as Map;
    expect(r['isError'], false);
    final doc = jsonDecode((r['content']! as List).first['text'] as String) as Map;
    expect(doc['name'], 'AstryxButton');
  });

  test('tools/call on unknown component returns a tool error', () {
    final r = result(call('tools/call', {'name': 'astryx_get_component', 'arguments': {'name': 'Nope'}})) as Map;
    expect(r['isError'], true);
  });

  test('resources/read serves the manifest and a11y guidelines', () {
    final manifest = result(call('resources/read', {'uri': 'astryx://manifest'})) as Map;
    expect((manifest['contents']! as List).first['mimeType'], 'application/json');

    final a11y = result(call('resources/read', {'uri': 'astryx://guidelines/a11y'})) as Map;
    expect((a11y['contents']! as List).first['text'], contains('Contrast'));
  });

  test('unknown method yields JSON-RPC method-not-found', () {
    final resp = call('bogus/method');
    expect((resp!['error']! as Map)['code'], -32601);
  });
}
