import 'model.dart';
import 'ops.dart';
import 'registry.dart';
import 'templates.dart';

/// The tooling version reported by the manifest.
const String astryxToolVersion = '0.1.0';

/// The built-in theme names (kept in sync with astryx_themes' catalog).
const List<String> astryxThemeNames = [
  'neutral', 'daily', 'butter', 'chocolate', 'matcha', 'stone',
  'gothic', 'brutalist', 'meta', 'whatsapp', 'y2k',
];

/// All components (the registry).
List<AstryxComponentDoc> listComponents() => astryxRegistry;

/// Distinct categories, in first-seen order.
List<String> listCategories() {
  final seen = <String>[];
  for (final c in astryxRegistry) {
    if (!seen.contains(c.category)) seen.add(c.category);
  }
  return seen;
}

/// Finds a component by name (case-insensitive; the `Astryx` prefix optional).
AstryxComponentDoc? findComponent(String name) {
  String norm(String s) => s.toLowerCase().replaceFirst('astryx', '');
  final target = norm(name);
  for (final c in astryxRegistry) {
    if (norm(c.name) == target) return c;
  }
  return null;
}

/// The plan for ejecting [name] into a consumer repo (source-available swizzle).
Map<String, Object?>? swizzlePlan(String name) {
  final c = findComponent(name);
  if (c == null) return null;
  final slug = _slug(c.name);
  return {
    'component': c.name,
    'category': c.category.toLowerCase().replaceAll(' ', '_'),
    'sourceFiles': ['$slug.dart', if (_hasStyle(c)) '${slug}_style.dart'],
    'copyTo': 'lib/astryx/${c.category.toLowerCase().replaceAll(' ', '_')}/$slug/',
    'dependencies': ['astryx_tokens', 'astryx_foundations'],
    'note': 'Consider a per-instance *Style override before swizzling.',
  };
}

bool _hasStyle(AstryxComponentDoc c) => c.props.any((p) => p.name == 'style');

String _slug(String pascal) {
  final b = StringBuffer();
  for (var i = 0; i < pascal.length; i++) {
    final ch = pascal[i];
    final lower = ch.toLowerCase();
    if (ch != lower && i != 0) b.write('_');
    b.write(lower);
  }
  return b.toString();
}

/// The machine-readable contract — "an OpenAPI spec for the CLI": every
/// operation (command/tool), plus the full catalog of components, templates and
/// themes. The MCP server and the CLI both derive from [astryxOps], so their
/// surfaces cannot diverge.
Map<String, Object?> buildManifest() {
  return {
    'schemaVersion': '1',
    'tool': {
      'name': 'astryx',
      'aliases': ['xds'],
      'version': astryxToolVersion,
    },
    'operations': [for (final op in astryxOps) op.toJson()],
    'catalog': {
      'categories': listCategories(),
      'components': [
        for (final c in astryxRegistry)
          {'name': c.name, 'category': c.category, 'status': c.status.name},
      ],
      'templates': astryxTemplateNames,
      'themes': astryxThemeNames,
    },
  };
}

/// A human/agent-readable rendering of a component doc (used by the CLI's
/// non-JSON output and the MCP text content).
String renderComponentText(AstryxComponentDoc c) {
  final b = StringBuffer()
    ..writeln(c.name)
    ..writeln('  ${c.category} · ${c.status.name}${c.a11yRole != null ? ' · role: ${c.a11yRole}' : ''}')
    ..writeln()
    ..writeln('  ${c.description}')
    ..writeln()
    ..writeln('  Props:');
  for (final p in c.props) {
    final req = p.required ? ' (required)' : '';
    final def = p.defaultValue != null ? ' = ${p.defaultValue}' : '';
    b.writeln('    - ${p.name}: ${p.type}$req$def');
  }
  if (c.slots.isNotEmpty) b.writeln('  Slots: ${c.slots.join(', ')}');
  if (c.composesWith.isNotEmpty) b.writeln('  Composes with: ${c.composesWith.join(', ')}');
  b
    ..writeln()
    ..writeln('  Example:')
    ..writeln('    ${c.sample}');
  return b.toString();
}
