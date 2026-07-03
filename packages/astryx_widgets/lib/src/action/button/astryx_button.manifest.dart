import 'package:astryx_foundations/astryx_foundations.dart';

/// Registry metadata for [AstryxButton]. Harvested (with the widget's
/// constructor params) into `registry.g.json` by the J7 registry generator.
@AstryxComponent(
  category: 'Action',
  status: AstryxStatus.beta,
  a11yRole: 'button',
  composesWith: ['Toolbar', 'Dialog', 'FormLayout'],
  slots: ['leading', 'trailing'],
  sample: '''
AstryxButton(
  label: 'Save',
  variant: AstryxButtonVariant.primary,
  onPressed: () {},
)''',
)
const astryxButtonManifest = 'AstryxButton';
