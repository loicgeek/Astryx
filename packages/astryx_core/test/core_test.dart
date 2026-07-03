import 'package:astryx_core/astryx_core.dart';
import 'package:test/test.dart';

void main() {
  test('registry covers the component set with valid entries', () {
    expect(astryxRegistry.length, greaterThanOrEqualTo(30));
    for (final c in astryxRegistry) {
      expect(c.name, startsWith('Astryx'));
      expect(c.category, isNotEmpty);
      expect(c.sample, isNotEmpty);
      expect(c.props, isNotEmpty);
    }
  });

  test('findComponent is case-insensitive and prefix-optional', () {
    expect(findComponent('AstryxButton')?.name, 'AstryxButton');
    expect(findComponent('button')?.name, 'AstryxButton');
    expect(findComponent('SLIDER')?.name, 'AstryxSlider');
    expect(findComponent('nope'), isNull);
  });

  test('manifest declares tool, operations and a full catalog', () {
    final m = buildManifest();
    expect((m['tool']! as Map)['aliases'], contains('xds'));
    final ops = m['operations']! as List;
    expect(ops.map((o) => (o as Map)['cli']), containsAll(['list', 'component', 'manifest', 'swizzle']));
    final catalog = m['catalog']! as Map;
    expect((catalog['components']! as List).length, astryxRegistry.length);
    expect(catalog['themes'], contains('brutalist'));
    expect(catalog['templates'], astryxTemplateNames);
  });

  test('swizzle plan lists source files, target and deps', () {
    final plan = swizzlePlan('button')!;
    expect(plan['component'], 'AstryxButton');
    expect(plan['sourceFiles'], contains('astryx_button.dart'));
    expect(plan['dependencies'], containsAll(['astryx_tokens', 'astryx_foundations']));
  });

  test('templates render for known names and null otherwise', () {
    expect(renderTemplate('dashboard'), contains('AstryxAppShell'));
    expect(renderTemplate('form'), contains('AstryxField'));
    expect(renderTemplate('unknown'), isNull);
  });
}
