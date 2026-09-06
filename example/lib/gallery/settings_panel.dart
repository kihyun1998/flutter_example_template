// The three settings panes composed into one 320-wide column.
//
// The shell hands a destination a region and asks it to fill it; how the panes
// are arranged in there is this consumer's decision, not the shell's. Side by
// side is what a wide knob region would want; at 320 they stack.

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import 'host.dart';
import 'settings.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key, required this.notifier});

  final GallerySettingsNotifier notifier;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  String _openFeatureId = 'labels';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        // Rebuilt from the current settings every time they change. The host is
        // a value, not a store.
        final host = GalleryHost(widget.notifier);

        return Column(
          children: [
            PresetBar(host: host),
            Expanded(
              flex: 2,
              child: FeatureListPane(
                host: host,
                selectedFeatureId: _openFeatureId,
                onFeatureSelected: (id) =>
                    setState(() => _openFeatureId = id),
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Expanded(
              flex: 3,
              child: FeatureDetailPane(
                host: host,
                feature: featureIn(host.spec, _openFeatureId),
              ),
            ),
          ],
        );
      },
    );
  }
}
