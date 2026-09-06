import 'package:example/gallery/host.dart';
import 'package:example/gallery/settings.dart';
import 'package:example/gallery/settings_panel.dart';
import 'package:example/scenarios/editor_toolbar.dart';
import 'package:example/subject/adaptive_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

// `setting_spec.dart` says a spec is held honest by the app that owns it, by a
// test that reddens on an id naming nothing. This is that test.
//
// It exists because this app fell into the trap `SettingsHost.control`
// describes: it answered for the options and not for the switches, and threw on
// the first feature with a switch. In a release build that is a grey box where
// the pane should be, and nothing anywhere reports it.

void main() {
  late GallerySettingsNotifier notifier;

  setUp(() => notifier = GallerySettingsNotifier());
  tearDown(() => notifier.dispose());

  group('the spec and the host answer to each other', () {
    test('every id the spec names, the host can build a control for', () {
      final host = GalleryHost(notifier);
      final ids = <String>[
        for (final group in host.spec)
          for (final feature in group.features) ...[
            if (feature.switchId != null) feature.switchId!,
            ...feature.options,
          ],
      ];

      expect(ids, isNotEmpty, reason: 'The spec names nothing to check.');

      for (final id in ids) {
        expect(
          () => host.control(id),
          returnsNormally,
          reason: '$id is in the spec and the host cannot build it.',
        );
      }
    });

    test('every interaction points at a feature that exists', () {
      // A citation to a feature id that is not in the spec renders a card
      // naming nothing.
      final host = GalleryHost(notifier);
      final known = {
        for (final group in host.spec)
          for (final feature in group.features) feature.id,
      };

      for (final group in host.spec) {
        for (final feature in group.features) {
          for (final interaction in feature.interactions) {
            expect(
              known,
              contains(interaction.otherFeatureId),
              reason: '${feature.id} claims to affect '
                  '${interaction.otherFeatureId}, which is not in the spec.',
            );
          }
        }
      }
    });

    test("the Crowded preset's guidance says a number the bar agrees with", () {
      // `lookFor` is prose with a count in it, and a count in prose drifts. The
      // first version of this said the phone frame keeps *two*; a screenshot
      // showed three. Held here so the sentence cannot go quietly wrong again.
      //
      final crowded = presetSettings['crowded']!;
      final survive = AdaptiveActionBar.fitCount(
        demoActions.take(crowded.actionCount).toList(),
        // Derived, not copied: the same expression the readout uses, so the
        // guard reads the width the bar is given rather than a number that
        // agreed with it once.
        ViewportSpec.mobile.width - EditorToolbar.horizontalInset,
        showLabels: crowded.showLabels,
        density: crowded.density,
        allowOverflow: crowded.allowOverflow,
      );

      expect(survive, 3);
      expect(
        galleryPresets.firstWhere((p) => p.id == 'crowded').lookFor,
        contains('keeps three'),
        reason: 'The bar fits $survive at phone width and the guidance says '
            'otherwise. One of the two is wrong.',
      );
    });

    test('every preset the bar offers can actually be applied', () {
      final host = GalleryHost(notifier);
      for (final preset in host.presets) {
        host.applyPreset(preset.id);
        expect(
          host.activePresetId,
          preset.id,
          reason: 'Applying ${preset.id} did not make it the active preset, so '
              'the chip goes back to unselected the moment it is pressed.',
        );
      }
    });
  });

  testWidgets('all three panes draw, in a 320-wide knob region', (tester) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SettingsPanel(notifier: notifier))),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PresetBar), findsOneWidget);
    expect(find.byType(FeatureListPane), findsOneWidget);
    expect(find.byType(FeatureDetailPane), findsOneWidget);

    // Being in the tree is not the same as having drawn anything.
    expect(
      find.descendant(
        of: find.byType(FeatureDetailPane),
        matching: find.text('Labels'),
      ),
      findsOneWidget,
      reason: 'The detail pane holds a region but shows nothing in it.',
    );
  });
}
