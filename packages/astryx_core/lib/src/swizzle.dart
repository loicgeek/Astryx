import 'dart:io';

import 'services.dart';

/// The outcome of a swizzle operation.
class SwizzleReport {
  SwizzleReport({
    required this.component,
    required this.targetDir,
    required this.filesWritten,
    required this.rewrites,
    required this.warnings,
    required this.dryRun,
  });

  final String component;
  final String targetDir;
  final List<String> filesWritten;

  /// Human-readable "from → to" import rewrites applied.
  final List<String> rewrites;

  /// Non-fatal issues (e.g. private cross-component deps that keep a dependency
  /// on astryx_widgets).
  final List<String> warnings;
  final bool dryRun;

  Map<String, Object?> toJson() => {
        'component': component,
        'targetDir': targetDir,
        'dryRun': dryRun,
        'filesWritten': filesWritten,
        'rewrites': rewrites,
        'warnings': warnings,
      };
}

/// Ejects [name]'s source into [outDir] (a consumer project root), rewriting
/// imports so the copied component is self-contained where possible.
///
/// - Same-folder relative imports are kept (the files are copied together).
/// - `package:astryx_tokens` / `package:astryx_foundations` / `flutter` / `dart:`
///   imports are kept (the consumer keeps those as dependencies).
/// - Relative imports that escape the component folder are rewritten to the
///   `astryx_widgets` barrel; private ones (internal/ or `_`-prefixed) can't be
///   reached that way and are reported as warnings.
///
/// [widgetsSrcDir] is the path to `astryx_widgets/lib/src`. When [dryRun] is
/// true (default) no files are written; the report describes what would happen.
SwizzleReport swizzleComponent({
  required String name,
  required String widgetsSrcDir,
  required String outDir,
  bool dryRun = true,
}) {
  final doc = findComponent(name);
  final resolvedName = doc?.name ?? name;
  final slug = _slug(resolvedName);

  final folder = _findComponentFolder(Directory(widgetsSrcDir), slug);
  if (folder == null) {
    throw SwizzleException(
      'No swizzle-able source folder found for "$resolvedName" (looked for $slug.dart under $widgetsSrcDir). '
      'Function-based components (showAstryx*) cannot be swizzled.',
    );
  }

  final category = folder.parent.path.split(Platform.pathSeparator).last;
  final targetDir = _join([outDir, 'lib', 'astryx', category, slug]);

  final files = folder
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.manifest.dart'))
      .toList();

  final written = <String>[];
  final rewrites = <String>[];
  final warnings = <String>[];

  // Local file names in this folder → kept as relative imports.
  final localNames = files.map((f) => _basename(f.path)).toSet();

  for (final file in files) {
    final base = _basename(file.path);
    final rewritten = _rewriteImports(
      file.readAsStringSync(),
      localNames: localNames,
      onRewrite: (from, to) => rewrites.add('$base: $from → $to'),
      onWarn: warnings.add,
    );
    final targetPath = _join([targetDir, base]);
    written.add(targetPath);
    if (!dryRun) {
      final out = File(targetPath);
      out.parent.createSync(recursive: true);
      out.writeAsStringSync(rewritten);
    }
  }

  return SwizzleReport(
    component: resolvedName,
    targetDir: targetDir,
    filesWritten: written,
    rewrites: rewrites,
    warnings: warnings,
    dryRun: dryRun,
  );
}

String _rewriteImports(
  String content, {
  required Set<String> localNames,
  required void Function(String from, String to) onRewrite,
  required void Function(String) onWarn,
}) {
  const barrel = "package:astryx_widgets/astryx_widgets.dart";
  final importRe = RegExp(r"""^(\s*(?:import|export)\s+)'([^']+)'(.*)$""");
  final lines = content.split('\n');
  final out = <String>[];
  var barrelAdded = false;

  for (final line in lines) {
    final m = importRe.firstMatch(line);
    if (m == null) {
      out.add(line);
      continue;
    }
    final uri = m.group(2)!;
    final keep = uri.startsWith('dart:') ||
        uri.startsWith('package:astryx_tokens/') ||
        uri.startsWith('package:astryx_foundations/') ||
        uri.startsWith('package:flutter/');
    if (keep) {
      out.add(line);
      continue;
    }
    // Relative import.
    if (!uri.startsWith('package:')) {
      final base = _basename(uri);
      if (!uri.contains('/') && localNames.contains(base)) {
        out.add(line); // same-folder file, copied alongside
        continue;
      }
      // Escapes the folder → route through the barrel, if it's public.
      final isPrivate = uri.contains('/internal/') || base.startsWith('_');
      if (isPrivate) {
        onWarn('$uri is a private cross-component dependency; the swizzled copy '
            'still needs astryx_widgets for it. Consider swizzling it too.');
      }
      onRewrite(uri, barrel);
      if (!barrelAdded) {
        out.add("${m.group(1)}'$barrel'${m.group(3)}");
        barrelAdded = true;
      }
      continue;
    }
    // Any other package import (e.g. astryx_widgets itself) → keep.
    out.add(line);
  }
  return out.join('\n');
}

Directory? _findComponentFolder(Directory root, String slug) {
  if (!root.existsSync()) return null;
  for (final e in root.listSync(recursive: true)) {
    if (e is File && _basename(e.path) == '$slug.dart') return e.parent;
  }
  return null;
}

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

String _basename(String path) => path.split(RegExp(r'[\\/]')).last;
String _join(List<String> parts) => parts.join(Platform.pathSeparator);

class SwizzleException implements Exception {
  SwizzleException(this.message);
  final String message;
  @override
  String toString() => message;
}
