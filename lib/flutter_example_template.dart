/// A shell that demonstrates a package without knowing which one.
///
/// A menu of destinations, a viewport-aware preview stage with a device wall, a
/// source pane that reads the running file, a settings panel, and the app chrome
/// around them. **Nothing here names a subject**, and
/// `test/portable_seam_test.dart` holds it to that by walking the tree rather
/// than trusting the intention.
///
/// Three ports carry everything a consumer has to supply: [ShellDestinations]
/// for what the menu points at and how long it lives, [SettingsHost] for a
/// settings panel over a settings object this package must not name, and
/// [PresetSummary] for named combinations. Every member on them was read off a
/// call site rather than designed.
///
/// **This barrel is the entry point, and that is a rule rather than a
/// convenience.** Nothing outside `lib/src/` may import into it. Dart makes
/// `src/` private by naming agreement and by nothing else — a consumer's
/// `package:…/src/x.dart` resolves fine and compiles, right up until the day
/// somebody enforces the convention. A symbol is exported here or it is not
/// public.
library;

export 'src/perf/performance_monitor.dart';
export 'src/preview/device_wall.dart';
export 'src/preview/preview_frame.dart';
export 'src/preview/preview_stage.dart';
export 'src/preview/viewport_spec.dart';
export 'src/settings/feature_detail_pane.dart';
export 'src/settings/feature_list_pane.dart';
export 'src/settings/feature_search.dart';
export 'src/settings/preset_bar.dart';
export 'src/settings/setting_spec.dart';
export 'src/settings/settings_host.dart';
export 'src/settings/settings_controls.dart';
export 'src/shell/dart_highlighter.dart';
export 'src/shell/shell_destination.dart';
export 'src/shell/shell_destinations.dart';
export 'src/shell/shell_menu.dart';
export 'src/shell/shell_page.dart';
export 'src/shell/source_pane.dart';
export 'src/theme/example_theme.dart';
export 'src/theme/theme_mode_button.dart';
