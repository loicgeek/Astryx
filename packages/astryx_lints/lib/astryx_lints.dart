import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/avoid_material_import.dart';
import 'src/prefer_tokens_over_raw_color.dart';

/// custom_lint entry point. Enable in a consumer project by adding
/// `custom_lint` + `astryx_lints` to dev_dependencies and:
///
/// ```yaml
/// # analysis_options.yaml
/// analyzer:
///   plugins:
///     - custom_lint
/// ```
PluginBase createPlugin() => _AstryxLintsPlugin();

class _AstryxLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidMaterialImport(),
        PreferTokensOverRawColor(),
      ];
}
