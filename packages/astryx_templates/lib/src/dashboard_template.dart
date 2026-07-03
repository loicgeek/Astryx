import 'package:astryx_foundations/astryx_foundations.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/widgets.dart';

/// A KPI shown in the dashboard's stat grid.
class AstryxKpi {
  const AstryxKpi({required this.label, required this.value});
  final String label;
  final String value;
}

/// {@template astryx.dashboardtemplate}
/// An opinionated dashboard screen: an App Shell (top nav + side nav) over a
/// KPI grid and a [content] region. Drop it in and adapt.
/// {@endtemplate}
class AstryxDashboardTemplate extends StatelessWidget {
  const AstryxDashboardTemplate({
    super.key,
    this.brand = 'Acme',
    this.title = 'Overview',
    this.kpis = const [
      AstryxKpi(label: 'Revenue', value: r'$1.2M'),
      AstryxKpi(label: 'Users', value: '18,204'),
      AstryxKpi(label: 'Churn', value: '2.1%'),
      AstryxKpi(label: 'MRR', value: r'$98k'),
    ],
    this.content,
    this.selectedNav = 'overview',
    this.onNavSelect,
  });

  final String brand;
  final String title;
  final List<AstryxKpi> kpis;
  final Widget? content;
  final String selectedNav;
  final ValueChanged<String>? onNavSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AstryxAppShell(
      topNav: AstryxTopNav(
        leading: AstryxText(brand, variant: AstryxTextVariant.label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      sideNav: AstryxSideNav<String>(
        selected: selectedNav,
        onSelect: onNavSelect ?? (_) {},
        sections: const [
          AstryxNavSection(title: 'Workspace', items: [
            AstryxNavItem(value: 'overview', label: 'Overview', icon: _Dot()),
            AstryxNavItem(value: 'reports', label: 'Reports', icon: _Dot()),
            AstryxNavItem(value: 'team', label: 'Team', icon: _Dot()),
          ]),
        ],
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.all(t.spacing.insetLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: t.spacing.gapLg,
          children: [
            AstryxHeading(title, level: AstryxHeadingLevel.display),
            AstryxGrid(
              columns: const ResponsiveValue<int>(xs: 1, sm: 2, lg: 4),
              children: [
                for (final kpi in kpis)
                  AstryxCard(
                    variant: AstryxCardVariant.raised,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: t.spacing.gapSm,
                      children: [
                        AstryxText(kpi.label, tone: AstryxTextTone.muted),
                        AstryxHeading(kpi.value, level: AstryxHeadingLevel.h1),
                      ],
                    ),
                  ),
              ],
            ),
            if (content != null) content!,
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => const SizedBox(width: 8, height: 8);
}
