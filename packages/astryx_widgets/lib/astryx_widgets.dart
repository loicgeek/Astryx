/// Astryx UI components for Flutter.
///
/// Every component reads only semantic tokens (see `astryx_tokens`) so any
/// theme drives it, exposes a per-instance `*Style` override, and ships full
/// source (swizzle-ready).
library astryx_widgets;

// Action
export 'src/action/button/astryx_button.dart';
export 'src/action/button/astryx_button_style.dart';

// Feedback
export 'src/feedback/badge/astryx_badge.dart';
export 'src/feedback/banner/astryx_banner.dart';
export 'src/feedback/spinner/astryx_spinner.dart';

// Content
export 'src/content/avatar/astryx_avatar.dart';
export 'src/content/code/astryx_code.dart';
export 'src/content/heading/astryx_heading.dart';
export 'src/content/text/astryx_text.dart';
