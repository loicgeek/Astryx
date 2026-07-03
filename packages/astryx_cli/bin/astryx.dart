import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:astryx_cli/src/runner.dart';

Future<void> main(List<String> args) async {
  final runner = buildAstryxRunner();
  try {
    final code = await runner.run(args) ?? 0;
    exitCode = code;
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln();
    stderr.writeln(e.usage);
    exitCode = 64;
  }
}
