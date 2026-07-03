/// Astryx UI components for Flutter.
///
/// Every component reads only semantic tokens (see `astryx_tokens`) so any
/// theme drives it, exposes a per-instance `*Style` override, and ships full
/// source (swizzle-ready).
library astryx_widgets;

// Theme-level component overrides
export 'src/theme/astryx_component_styles.dart';

// Action
export 'src/action/button/astryx_button.dart';
export 'src/action/button/astryx_button_style.dart';
export 'src/action/dropdown_menu/astryx_dropdown_menu.dart';
export 'src/action/segmented_control/astryx_segmented_control.dart';

// Overlay
export 'src/overlay/dialog/astryx_dialog.dart';
export 'src/overlay/popover/astryx_popover.dart';
export 'src/overlay/toast/astryx_toast.dart';
export 'src/overlay/tooltip/astryx_tooltip.dart';

// Data Input
export 'src/data_input/checkbox/astryx_checkbox.dart';
export 'src/data_input/field/astryx_field.dart';
export 'src/data_input/slider/astryx_slider.dart';
export 'src/data_input/switch/astryx_switch.dart';
export 'src/data_input/text_input/astryx_text_input.dart';

// Layout
export 'src/layout/divider/astryx_divider.dart';
export 'src/layout/grid/astryx_grid.dart';
export 'src/layout/section/astryx_section.dart';

// Feedback
export 'src/feedback/badge/astryx_badge.dart';
export 'src/feedback/banner/astryx_banner.dart';
export 'src/feedback/spinner/astryx_spinner.dart';

// Content
export 'src/content/avatar/astryx_avatar.dart';
export 'src/content/code/astryx_code.dart';
export 'src/content/heading/astryx_heading.dart';
export 'src/content/text/astryx_text.dart';
