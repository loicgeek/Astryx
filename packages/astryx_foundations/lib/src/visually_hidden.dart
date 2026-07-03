import 'package:flutter/widgets.dart';

/// Screen-reader-only content: exposes [label] to assistive technology while
/// occupying no visual space. Direct port of Astryx's `VisuallyHidden` utility.
///
/// Use for context that sighted users infer visually but which a screen reader
/// would otherwise miss (e.g. "opens in new tab", a sortable column's state).
class VisuallyHidden extends StatelessWidget {
  const VisuallyHidden(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: const SizedBox.shrink(),
    );
  }
}
