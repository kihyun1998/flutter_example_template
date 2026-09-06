// This consumer's implementation of the settings port.
//
// A short-lived value, rebuilt on every build from the current settings and
// handed to the panes. It is not a store: the state lives in the notifier the
// destinations own.

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import '../scenarios/editor_toolbar.dart';
import '../subject/adaptive_action_bar.dart';
import 'settings.dart';

class GalleryHost extends SettingsHost {
  GalleryHost(this.notifier);

  final GallerySettingsNotifier notifier;

  GallerySettings get _s => notifier.value;

  @override
  List<SettingGroup> get spec => settingsSpec;

  @override
  bool isOn(String switchId) => switch (switchId) {
    'showLabels' => _s.showLabels,
    'allowOverflow' => _s.allowOverflow,
    'showDivider' => _s.showDivider,
    _ => throw ArgumentError.value(switchId, 'switchId', 'no such switch'),
  };

  @override
  void setSwitch(String switchId, bool on) {
    notifier.value = switch (switchId) {
      'showLabels' => _s.copyWith(showLabels: on),
      'allowOverflow' => _s.copyWith(allowOverflow: on),
      'showDivider' => _s.copyWith(showDivider: on),
      _ => throw ArgumentError.value(switchId, 'switchId', 'no such switch'),
    };
  }

  /// Every id the spec names — a feature's switch as well as its options.
  ///
  /// The switch belongs here too; `SettingsHost.control` says why, and this app
  /// is the one that got it wrong. `test/settings_panel_test.dart` walks the
  /// whole spec so a new id cannot arrive here unanswered.
  @override
  SettingsControl control(String settingId) => switch (settingId) {
    'showLabels' => buildSwitchTile(
      id: 'showLabels',
      label: 'Show labels',
      value: _s.showLabels,
      onChanged: (on) => setSwitch('showLabels', on),
    ),
    'allowOverflow' => buildSwitchTile(
      id: 'allowOverflow',
      label: 'Overflow menu',
      value: _s.allowOverflow,
      onChanged: (on) => setSwitch('allowOverflow', on),
    ),
    'showDivider' => buildSwitchTile(
      id: 'showDivider',
      label: 'Rules between actions',
      value: _s.showDivider,
      onChanged: (on) => setSwitch('showDivider', on),
    ),
    'density' => buildDropdownRow<ActionBarDensity>(
      id: 'density',
      label: 'Action density',
      value: _s.density,
      items: ActionBarDensity.values,
      itemLabel: (d) => d.label,
      onChanged: (d) => notifier.value = _s.copyWith(density: d),
    ),
    'alignment' => buildDropdownRow<ActionBarAlignment>(
      id: 'alignment',
      label: 'Alignment',
      value: _s.alignment,
      items: ActionBarAlignment.values,
      itemLabel: (a) => a.label,
      onChanged: (a) => notifier.value = _s.copyWith(alignment: a),
    ),
    'actionCount' => buildSliderSetting(
      id: 'actionCount',
      label: 'Action count',
      value: _s.actionCount.toDouble(),
      min: 2,
      max: demoActions.length.toDouble(),
      unit: '',
      onChanged: (v) => notifier.value = _s.copyWith(actionCount: v.round()),
    ),
    _ => throw ArgumentError.value(settingId, 'settingId', 'no such setting'),
  };

  /// The readout the registry cannot express.
  ///
  /// This is what the extras hook is for: a number that has to be computed from
  /// the settings rather than edited, and that no control could return. It is
  /// also where the severity comes from — the thresholds are about action bars,
  /// which is exactly the knowledge the panel must not have.
  @override
  List<Widget> extrasAfterOptions(String featureId, BuildContext context) {
    if (featureId != 'actions') return const [];

    final actions = demoActions.take(_s.actionCount).toList();
    final fits = AdaptiveActionBar.fitCount(
      actions,
      // The width the bar actually gets in the wall's phone frame, derived
      // from the viewport and the toolbar rather than written down again.
      ViewportSpec.mobile.width - EditorToolbar.horizontalInset,
      showLabels: _s.showLabels,
      density: _s.density,
      allowOverflow: _s.allowOverflow,
    );
    final each = AdaptiveActionBar.widthOf(
      actions.first,
      showLabels: _s.showLabels,
      density: _s.density,
    );

    return [
      const SizedBox(height: 16),
      MetricsPanel(
        title: 'At phone width',
        metrics: Metrics(
          lastUpdate: DateTime.now(),
          readings: [
            Reading(
              label: 'Actions',
              value: '${actions.length}',
              icon: Icons.tune,
            ),
            Reading(
              label: 'Width each',
              value: '${each.round()} px',
              subtitle: _s.showLabels ? 'label included' : 'icon only',
              icon: Icons.straighten,
            ),
            Reading(
              label: 'Survive',
              value: '$fits of ${actions.length}',
              icon: Icons.visibility_outlined,
              severity: switch (fits) {
                _ when fits == actions.length => ReadingSeverity.normal,
                <= 1 => ReadingSeverity.critical,
                <= 2 => ReadingSeverity.high,
                _ => ReadingSeverity.notable,
              },
            ),
          ],
        ),
      ),
    ];
  }

  @override
  List<PresetSummary> get presets => galleryPresets;

  @override
  String? get activePresetId {
    for (final entry in presetSettings.entries) {
      if (entry.value == _s) return entry.key;
    }
    return null;
  }

  @override
  void applyPreset(String presetId) {
    final next = presetSettings[presetId];
    if (next != null) notifier.value = next;
  }
}
