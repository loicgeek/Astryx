/// Names of the built-in page templates the CLI/MCP can emit.
const List<String> astryxTemplateNames = ['dashboard', 'form', 'settings'];

/// Returns a full Flutter screen source for [name], or null if unknown. These
/// are opinionated compositions of Astryx components an agent (or human) can
/// drop in and adapt.
String? renderTemplate(String name) {
  switch (name.toLowerCase()) {
    case 'dashboard':
      return _dashboard;
    case 'form':
      return _form;
    case 'settings':
      return _settings;
    default:
      return null;
  }
}

const _dashboard = r'''
import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AstryxAppShell(
      topNav: const AstryxTopNav(leading: Text('Acme')),
      sideNav: AstryxSideNav<String>(
        selected: 'overview',
        onSelect: (_) {},
        sections: const [
          AstryxNavSection(title: 'Workspace', items: [
            AstryxNavItem(value: 'overview', label: 'Overview', icon: Icon(Icons.dashboard)),
            AstryxNavItem(value: 'reports', label: 'Reports', icon: Icon(Icons.bar_chart)),
          ]),
        ],
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.all(t.spacing.insetLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: t.spacing.gapLg,
          children: [
            const AstryxHeading('Overview'),
            AstryxGrid(
              columns: const ResponsiveValue<int>(xs: 1, sm: 2, lg: 4),
              children: [
                for (final kpi in const ['Revenue', 'Users', 'Churn', 'MRR'])
                  AstryxCard(
                    variant: AstryxCardVariant.raised,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AstryxText(kpi, tone: AstryxTextTone.muted),
                        const AstryxHeading('1,234', level: AstryxHeadingLevel.h2),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
''';

const _form = r'''
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});
  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _email = TextEditingController();
  bool _terms = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AstryxHeading('Create your account'),
        const SizedBox(height: 16),
        AstryxField(
          label: 'Email',
          required: true,
          child: AstryxTextInput(controller: _email, hintText: 'you@example.com'),
        ),
        const SizedBox(height: 16),
        AstryxCheckbox(
          value: _terms,
          label: 'I agree to the terms',
          onChanged: (v) => setState(() => _terms = v),
        ),
        const SizedBox(height: 24),
        AstryxButton(label: 'Sign up', onPressed: _terms ? () {} : null),
      ],
    );
  }
}
''';

const _settings = r'''
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return AstryxSection(
      title: 'Preferences',
      description: 'Manage how the app behaves.',
      child: Column(
        children: [
          AstryxSwitch(
            value: _notifications,
            semanticLabel: 'Email notifications',
            onChanged: (v) => setState(() => _notifications = v),
          ),
          const AstryxCollapsible(
            title: 'Advanced',
            child: AstryxText('Danger zone lives here.'),
          ),
        ],
      ),
    );
  }
}
''';
