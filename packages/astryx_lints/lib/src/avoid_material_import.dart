import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Warns when a file imports `package:flutter/material.dart`. Astryx is
/// Material-free: import `package:flutter/widgets.dart` and use Astryx
/// components (which carry the brand look) instead of Material widgets.
class AvoidMaterialImport extends DartLintRule {
  AvoidMaterialImport() : super(code: _code);

  static const _code = LintCode(
    name: 'astryx_avoid_material_import',
    problemMessage: 'Astryx is Material-free. Import package:flutter/widgets.dart and use '
        'Astryx components instead of package:flutter/material.dart.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addImportDirective((node) {
      if (node.uri.stringValue == 'package:flutter/material.dart') {
        reporter.atNode(node, _code);
      }
    });
  }
}
