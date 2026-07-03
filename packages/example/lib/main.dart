import 'package:astryx_themes/astryx_themes.dart';
import 'package:astryx_tokens/astryx_tokens.dart';
import 'package:astryx_widgets/astryx_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AstryxGalleryApp());

class AstryxGalleryApp extends StatefulWidget {
  const AstryxGalleryApp({super.key});

  @override
  State<AstryxGalleryApp> createState() => _AstryxGalleryAppState();
}

class _AstryxGalleryAppState extends State<AstryxGalleryApp> {
  final AstryxThemeData _theme = AstryxThemeData.neutral();
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astryx Gallery',
      debugShowCheckedModeBanner: false,
      theme: _theme.light,
      darkTheme: _theme.dark,
      themeMode: _mode,
      home: GalleryScreen(
        themeName: _theme.name,
        mode: _mode,
        onToggleMode: () => setState(() {
          _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
        }),
      ),
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({
    super.key,
    required this.themeName,
    required this.mode,
    required this.onToggleMode,
  });

  final String themeName;
  final ThemeMode mode;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isDark = mode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: t.color.surfaceDefault,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(t.spacing.insetLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Astryx • $themeName', style: t.typography.display),
                  AstryxButton(
                    label: isDark ? 'Light' : 'Dark',
                    variant: AstryxButtonVariant.secondary,
                    leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: onToggleMode,
                  ),
                ],
              ),
              SizedBox(height: t.spacing.gapLg),
              _section(t, 'Variants', [
                const AstryxButton(label: 'Primary'),
                const AstryxButton(label: 'Secondary', variant: AstryxButtonVariant.secondary),
                const AstryxButton(label: 'Ghost', variant: AstryxButtonVariant.ghost),
                const AstryxButton(label: 'Danger', variant: AstryxButtonVariant.danger),
              ]),
              _section(t, 'Sizes', [
                AstryxButton(label: 'Small', size: AstryxButtonSize.sm, onPressed: () {}),
                AstryxButton(label: 'Medium', size: AstryxButtonSize.md, onPressed: () {}),
                AstryxButton(label: 'Large', size: AstryxButtonSize.lg, onPressed: () {}),
              ]),
              _section(t, 'States', [
                AstryxButton(label: 'Enabled', onPressed: () {}),
                const AstryxButton(label: 'Disabled'),
                const AstryxButton(label: 'Loading', loading: true),
                AstryxButton(
                  label: 'With icons',
                  variant: AstryxButtonVariant.secondary,
                  leading: const Icon(Icons.add),
                  trailing: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(AstryxTokens t, String title, List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(bottom: t.spacing.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.typography.heading),
          SizedBox(height: t.spacing.gapMd),
          Wrap(spacing: t.spacing.gapMd, runSpacing: t.spacing.gapMd, children: children),
        ],
      ),
    );
  }
}
