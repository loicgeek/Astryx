import 'dart:io';

import 'package:astryx_core/astryx_core.dart';
import 'package:test/test.dart';

// The test runs from packages/astryx_core, so the widgets source is a sibling.
const _widgetsSrc = '../astryx_widgets/lib/src';

void main() {
  test('dry run reports files + rewrites without writing anything', () {
    final dir = Directory.systemTemp.createTempSync('astryx_swizzle_dry');
    addTearDown(() => dir.deleteSync(recursive: true));

    final report = swizzleComponent(name: 'Button', widgetsSrcDir: _widgetsSrc, outDir: dir.path);
    expect(report.dryRun, isTrue);
    expect(report.filesWritten, hasLength(2)); // astryx_button.dart + _style.dart
    expect(dir.listSync(recursive: true).whereType<File>(), isEmpty); // nothing written
  });

  test('apply copies the source and rewrites escaping imports to the barrel', () {
    final dir = Directory.systemTemp.createTempSync('astryx_swizzle_apply');
    addTearDown(() => dir.deleteSync(recursive: true));

    final report = swizzleComponent(name: 'Button', widgetsSrcDir: _widgetsSrc, outDir: dir.path, dryRun: false);
    expect(report.warnings, isEmpty);

    final buttonFile = File('${report.targetDir}/astryx_button.dart');
    final styleFile = File('${report.targetDir}/astryx_button_style.dart');
    expect(buttonFile.existsSync(), isTrue);
    expect(styleFile.existsSync(), isTrue);

    final button = buttonFile.readAsStringSync();
    expect(button, contains("import 'package:astryx_tokens/astryx_tokens.dart';")); // kept
    expect(button, contains("import 'astryx_button_style.dart';")); // same-folder kept

    // The cross-folder AstryxComponentStyles import is routed through the barrel.
    final style = styleFile.readAsStringSync();
    expect(style, contains("import 'package:astryx_widgets/astryx_widgets.dart';"));
    expect(style, isNot(contains('../../theme/')));
  });

  test('unknown / unfindable component throws SwizzleException', () {
    final dir = Directory.systemTemp.createTempSync('astryx_swizzle_err');
    addTearDown(() => dir.deleteSync(recursive: true));
    expect(
      () => swizzleComponent(name: 'DoesNotExist', widgetsSrcDir: _widgetsSrc, outDir: dir.path),
      throwsA(isA<SwizzleException>()),
    );
  });
}
