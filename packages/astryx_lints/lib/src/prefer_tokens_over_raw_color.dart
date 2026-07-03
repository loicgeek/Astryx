import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Flags raw `Color(...)` construction. In Astryx UI code, prefer semantic
/// tokens (`context.tokens.color.*`) so theming and dark mode apply — reserve
/// raw colors for the token definitions themselves.
class PreferTokensOverRawColor extends DartLintRule {
  PreferTokensOverRawColor() : super(code: _code);

  static const _code = LintCode(
    name: 'astryx_prefer_tokens_over_raw_color',
    problemMessage: 'Prefer context.tokens.color.* over a raw Color literal so theming '
        'and dark mode work.',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInstanceCreationExpression((node) {
      // `toSource()` is stable across analyzer versions (avoids NamedType API churn).
      if (node.constructorName.type.toSource() == 'Color') {
        reporter.atNode(node, _code);
      }
    });
  }
}
