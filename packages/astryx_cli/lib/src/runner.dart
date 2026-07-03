import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:astryx_core/astryx_core.dart';

const _encoder = JsonEncoder.withIndent('  ');
String prettyJson(Object? value) => _encoder.convert(value);

/// Builds the `astryx` command runner. Exposed so tests can drive it directly.
CommandRunner<int> buildAstryxRunner() {
  return CommandRunner<int>('astryx', 'Astryx design system CLI (alias: xds).')
    ..addCommand(_ListCommand())
    ..addCommand(_ComponentCommand())
    ..addCommand(_TemplateCommand())
    ..addCommand(_ThemeCommand())
    ..addCommand(_SwizzleCommand())
    ..addCommand(_ManifestCommand());
}

class _ListCommand extends Command<int> {
  @override
  final name = 'list';
  @override
  final description = 'List all components with their category and status.';

  @override
  int run() {
    final data = [
      for (final c in listComponents())
        {'name': c.name, 'category': c.category, 'status': c.status.name},
    ];
    print(prettyJson(data));
    return 0;
  }
}

class _ComponentCommand extends Command<int> {
  _ComponentCommand() {
    argParser.addFlag('json', help: 'Emit the component doc as JSON.', negatable: false);
  }

  @override
  final name = 'component';
  @override
  final description = 'Show a component: description, props, a11y role, hints and a sample.';
  @override
  final invocation = 'astryx component <name> [--json]';

  @override
  int run() {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      printUsage();
      return 64;
    }
    final c = findComponent(rest.first);
    if (c == null) {
      stderrPrint('Unknown component: ${rest.first}');
      return 1;
    }
    print(argResults!.flag('json') ? prettyJson(c.toJson()) : renderComponentText(c));
    return 0;
  }
}

class _TemplateCommand extends Command<int> {
  @override
  final name = 'template';
  @override
  final description = 'Emit a full Flutter screen for a named template.';
  @override
  final invocation = 'astryx template <name>   (dashboard | form | settings)';

  @override
  int run() {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      print('Templates: ${astryxTemplateNames.join(', ')}');
      return 0;
    }
    final code = renderTemplate(rest.first);
    if (code == null) {
      stderrPrint('Unknown template: ${rest.first}. Available: ${astryxTemplateNames.join(', ')}');
      return 1;
    }
    print(code);
    return 0;
  }
}

class _ThemeCommand extends Command<int> {
  @override
  final name = 'theme';
  @override
  final description = 'List the built-in themes, or show one.';

  @override
  int run() {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      print(prettyJson(astryxThemeNames));
      return 0;
    }
    if (!astryxThemeNames.contains(rest.first)) {
      stderrPrint('Unknown theme: ${rest.first}');
      return 1;
    }
    print(prettyJson({
      'theme': rest.first,
      'usage': "MaterialApp(theme: AstryxThemeCatalog.byName('${rest.first}').light)",
    }));
    return 0;
  }
}

class _SwizzleCommand extends Command<int> {
  _SwizzleCommand() {
    argParser
      ..addOption('out', help: 'Consumer project root to copy the component into.', defaultsTo: '.')
      ..addOption('widgets-src', help: 'Path to astryx_widgets/lib/src (auto-detected in a monorepo).')
      ..addFlag('apply', help: 'Actually copy files (default is a dry run).', negatable: false);
  }

  @override
  final name = 'swizzle';
  @override
  final description = 'Eject a component into the consumer repo (copy source + rewrite imports).';
  @override
  final invocation = 'astryx swizzle <name> [--apply] [--out <dir>]';

  @override
  int run() {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      printUsage();
      return 64;
    }
    final widgetsSrc = (argResults!.option('widgets-src')) ?? _resolveWidgetsSrc();
    if (widgetsSrc == null) {
      stderrPrint('Could not locate astryx_widgets/lib/src. Pass --widgets-src.');
      return 1;
    }
    try {
      final report = swizzleComponent(
        name: rest.first,
        widgetsSrcDir: widgetsSrc,
        outDir: argResults!.option('out')!,
        dryRun: !argResults!.flag('apply'),
      );
      print(prettyJson(report.toJson()));
      return 0;
    } on SwizzleException catch (e) {
      stderrPrint(e.message);
      return 1;
    }
  }
}

/// Walks up from the current directory to find `packages/astryx_widgets/lib/src`.
String? _resolveWidgetsSrc() {
  var dir = Directory.current;
  for (var i = 0; i < 6; i++) {
    final candidate = Directory('${dir.path}/packages/astryx_widgets/lib/src');
    if (candidate.existsSync()) return candidate.path;
    final self = Directory('${dir.path}/lib/src');
    if (self.existsSync() && dir.path.endsWith('astryx_widgets')) return self.path;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}

class _ManifestCommand extends Command<int> {
  @override
  final name = 'manifest';
  @override
  final description = 'Emit the machine-readable contract (operations + full catalog).';

  @override
  int run() {
    print(prettyJson(buildManifest()));
    return 0;
  }
}

// Tiny indirection so tests can capture stderr uniformly.
void stderrPrint(String message) => print('error: $message');
