import 'package:astryx_core/astryx_core.dart';
import 'package:astryx_core/src/registry_props.g.dart';
import 'package:test/test.dart';

void main() {
  test('harvester covers the widget components with real constructor props', () {
    expect(harvestedProps.length, greaterThanOrEqualTo(40));

    // Props reflect the actual AstryxButton constructor (incl. ones that were
    // never hand-curated), with correct required flags.
    final button = harvestedProps['AstryxButton']!;
    final byName = {for (final p in button) p.name: p};
    expect(byName.keys, containsAll(['label', 'onPressed', 'variant', 'expand', 'semanticLabel']));
    expect(byName['label']!.required, isTrue);
    expect(byName['onPressed']!.required, isFalse);
    expect(byName['variant']!.defaultValue, 'AstryxButtonVariant.primary');
  });

  test('registry uses harvested props for widget components (no drift)', () {
    // For every component whose constructor was harvested, the exported registry
    // exposes exactly those props — so a widget component API cannot drift.
    for (final c in listComponents()) {
      if (!harvestedProps.containsKey(c.name)) continue;
      final registryNames = c.props.map((p) => p.name).toList();
      final harvestedNames = harvestedProps[c.name]!.map((p) => p.name).toList();
      expect(registryNames, harvestedNames, reason: '${c.name} props must come from the harvester');
    }
  });

  test('function-based components keep curated props (not harvested)', () {
    // e.g. AstryxToast is a show*-function, not a widget class → not harvested.
    expect(harvestedProps.containsKey('AstryxToast'), isFalse);
    expect(findComponent('AstryxToast')!.props, isNotEmpty);
  });
}
