// What the settings panel is described in, and the object it edits.
//
// Types and description live here, beside the app that owns them, because
// which settings exist is this consumer's business. The shell renders a
// description and holds none of it.

import 'package:flutter/foundation.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import '../subject/adaptive_action_bar.dart';

@immutable
class GallerySettings {
  const GallerySettings({
    this.showLabels = true,
    this.density = ActionBarDensity.comfortable,
    this.alignment = ActionBarAlignment.start,
    this.allowOverflow = true,
    this.showDivider = false,
    this.actionCount = 6,
  });

  final bool showLabels;
  final ActionBarDensity density;
  final ActionBarAlignment alignment;
  final bool allowOverflow;
  final bool showDivider;
  final int actionCount;

  GallerySettings copyWith({
    bool? showLabels,
    ActionBarDensity? density,
    ActionBarAlignment? alignment,
    bool? allowOverflow,
    bool? showDivider,
    int? actionCount,
  }) => GallerySettings(
    showLabels: showLabels ?? this.showLabels,
    density: density ?? this.density,
    alignment: alignment ?? this.alignment,
    allowOverflow: allowOverflow ?? this.allowOverflow,
    showDivider: showDivider ?? this.showDivider,
    actionCount: actionCount ?? this.actionCount,
  );

  // Equality is load-bearing rather than tidy: `activePresetId` is answered by
  // comparing the current settings against each preset's, so a preset stops
  // being active the moment anything is changed by hand.
  @override
  bool operator ==(Object other) =>
      other is GallerySettings &&
      other.showLabels == showLabels &&
      other.density == density &&
      other.alignment == alignment &&
      other.allowOverflow == allowOverflow &&
      other.showDivider == showDivider &&
      other.actionCount == actionCount;

  @override
  int get hashCode => Object.hash(
    showLabels,
    density,
    alignment,
    allowOverflow,
    showDivider,
    actionCount,
  );
}

/// The state behind every destination, owned for as long as the shell's page is.
///
/// This is what `ShellDestinations` exists to carry the lifetime of: the stage
/// and the knob pane both read it, and something has to dispose it.
class GallerySettingsNotifier extends ChangeNotifier {
  GallerySettings _value = const GallerySettings();
  GallerySettings get value => _value;

  set value(GallerySettings next) {
    if (next == _value) return;
    _value = next;
    notifyListeners();
  }
}

const settingsSpec = <SettingGroup>[
  SettingGroup(
    id: 'layout',
    title: 'Layout',
    features: [
      SettingFeature(
        id: 'labels',
        title: 'Labels',
        switchId: 'showLabels',
        interactions: [
          Interaction(
            otherFeatureId: 'overflow',
            effect:
                'Turning labels off drops each action to a fixed button width, '
                'so more of them survive before the bar overflows.',
            evidence: 'AdaptiveActionBar.widthOf returns early when showLabels '
                'is false.',
          ),
        ],
      ),
      SettingFeature(
        id: 'density',
        title: 'Density',
        options: ['density'],
        interactions: [
          Interaction(
            otherFeatureId: 'overflow',
            effect:
                'Dense narrows both the button and the per-character estimate, '
                'so the overflow threshold moves.',
            evidence: 'AdaptiveActionBar.widthOf branches on density twice.',
          ),
        ],
      ),
      SettingFeature(id: 'alignment', title: 'Alignment', options: ['alignment']),
    ],
  ),
  SettingGroup(
    id: 'overflow',
    title: 'Overflow',
    features: [
      SettingFeature(
        id: 'overflow',
        title: 'Overflow menu',
        switchId: 'allowOverflow',
        interactions: [
          Interaction(
            otherFeatureId: 'actions',
            effect:
                'With the menu off, actions that do not fit are not drawn at '
                'all rather than being moved.',
            evidence: 'AdaptiveActionBar.build draws the popup only when '
                'allowOverflow is true; fitCount reserves no room for it.',
          ),
        ],
      ),
      SettingFeature(id: 'divider', title: 'Divider', switchId: 'showDivider'),
    ],
  ),
  SettingGroup(
    id: 'content',
    title: 'Content',
    features: [
      SettingFeature(id: 'actions', title: 'Actions', options: ['actionCount']),
    ],
  ),
];

const galleryPresets = <PresetSummary>[
  PresetSummary(
    id: 'crowded',
    title: 'Crowded',
    lookFor:
        'Ten labelled actions. Open the Device Wall: the desktop frame keeps '
        'them all, the phone frame keeps two and menus the other eight.',
  ),
  PresetSummary(
    id: 'icons',
    title: 'Icons only',
    lookFor:
        'The same ten actions, no labels. The bar gives up text before it '
        'gives up actions — watch how much further the phone frame gets.',
  ),
  PresetSummary(
    id: 'tidy',
    title: 'Tidy',
    lookFor:
        'Five actions with rules between them. Nothing overflows at any width, '
        'so the overflow button never appears.',
  ),
];

const presetSettings = <String, GallerySettings>{
  'crowded': GallerySettings(actionCount: 10),
  'icons': GallerySettings(
    showLabels: false,
    density: ActionBarDensity.dense,
    actionCount: 10,
  ),
  'tidy': GallerySettings(actionCount: 5, showDivider: true),
};
