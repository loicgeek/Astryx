import 'dart:async';
import 'dart:convert';

import 'package:astryx_cli/src/runner.dart';
import 'package:test/test.dart';

/// Runs the CLI with [args], returning (exitCode, stdout).
Future<(int, String)> run(List<String> args) async {
  final out = StringBuffer();
  final code = await runZoned(
    () => buildAstryxRunner().run(args),
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => out.writeln(line),
    ),
  );
  return (code ?? 0, out.toString());
}

void main() {
  test('list emits JSON for every component', () async {
    final (code, out) = await run(['list']);
    expect(code, 0);
    final data = jsonDecode(out) as List;
    expect(data.any((e) => (e as Map)['name'] == 'AstryxButton'), isTrue);
  });

  test('component --json emits the component doc', () async {
    final (code, out) = await run(['component', 'button', '--json']);
    expect(code, 0);
    final doc = jsonDecode(out) as Map;
    expect(doc['name'], 'AstryxButton');
    expect(doc['a11yRole'], 'button');
  });

  test('component (text) prints a human-readable doc', () async {
    final (_, out) = await run(['component', 'Slider']);
    expect(out, contains('AstryxSlider'));
    expect(out, contains('Props:'));
  });

  test('unknown component exits non-zero', () async {
    final (code, _) = await run(['component', 'Nope']);
    expect(code, 1);
  });

  test('manifest is valid JSON with operations + catalog', () async {
    final (code, out) = await run(['manifest']);
    expect(code, 0);
    final m = jsonDecode(out) as Map;
    expect(m['operations'], isA<List>());
    expect((m['catalog']! as Map)['themes'], contains('neutral'));
  });

  test('template emits Flutter source', () async {
    final (code, out) = await run(['template', 'form']);
    expect(code, 0);
    expect(out, contains('AstryxField'));
  });
}
