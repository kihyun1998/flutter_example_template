/// Named measurements, drawn without knowing what they measure.
library;

import 'package:flutter/material.dart';

/// How much attention one reading is asking for.
///
/// **The thresholds are the subject's, so the severity arrives with the
/// reading rather than being computed here.** This panel used to decide it
/// itself, from a row count against 1 000 / 10 000 / 50 000 — three numbers
/// that are a fact about one kind of table and about nothing else. A gallery
/// that holds them is a gallery that knows its subject is a table.
enum ReadingSeverity { normal, notable, high, critical }

/// One named measurement, already formatted.
///
/// **[value] is a `String`, and that is the seam.** `128.4K`, `1.28s` and
/// `40K rows/sec` are three different formatting decisions and every one of
/// them belongs to whoever knows what is being counted. This file used to carry
/// all three — a thousands abbreviator, a millisecond-or-seconds switch, and a
/// rate that divided a count by a duration — which is the shape of a gallery
/// that knows one field is a tally and another is a stopwatch.
@immutable
class Reading {
  const Reading({
    required this.label,
    required this.value,
    this.subtitle,
    this.icon,
    this.severity = ReadingSeverity.normal,
  });

  /// What the reader is told this measures.
  final String label;

  /// The measurement, formatted by whoever took it.
  final String value;

  /// A second line under the label — a rate, a comparison, a qualifier.
  final String? subtitle;

  /// Optional, because an icon that means nothing is worse than none. The panel
  /// lays out the same either way.
  final IconData? icon;

  final ReadingSeverity severity;
}

/// A set of readings taken at one moment.
@immutable
class Metrics {
  const Metrics({required this.readings, required this.lastUpdate});

  final List<Reading> readings;

  /// When these were taken. Shown as an age rather than a clock time, because
  /// what a reader wants from it is whether they are looking at something stale.
  final DateTime lastUpdate;

  /// The loudest thing any reading is saying, for a summary that has room for
  /// one state and not for every reading.
  ReadingSeverity get severity => readings.isEmpty
      ? ReadingSeverity.normal
      : readings
            .map((r) => r.severity)
            .reduce((a, b) => a.index >= b.index ? a : b);
}

/// **Status colour is ink, never ground.** It survives on an icon and on a
/// value, where it sits on the surface and reads in either theme. As a *ground*
/// it does not: `shade50` is a light-theme decision, and a row of pale pastel
/// slabs in a dark app is how this pane used to look.
///
/// Semantic colour is the one exemption from the achromatic chrome — see
/// `exampleTheme`, which keeps `error` red for the same reason. A warning that
/// reads as a shade of grey is not a warning anyone notices. Everything at
/// [ReadingSeverity.normal] stays achromatic, so the hues that do appear are
/// carrying meaning rather than decorating rows.
Color _ink(ReadingSeverity severity, ColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  return switch (severity) {
    ReadingSeverity.normal => scheme.onSurface,
    ReadingSeverity.notable =>
      dark ? Colors.blue.shade300 : Colors.blue.shade800,
    ReadingSeverity.high =>
      dark ? Colors.orange.shade300 : Colors.orange.shade900,
    ReadingSeverity.critical => scheme.error,
  };
}

IconData _iconFor(ReadingSeverity severity) => switch (severity) {
  ReadingSeverity.normal => Icons.check_circle_outline,
  ReadingSeverity.notable => Icons.speed,
  ReadingSeverity.high => Icons.warning_amber,
  ReadingSeverity.critical => Icons.error_outline,
};

/// The readings in a titled box.
class MetricsPanel extends StatelessWidget {
  const MetricsPanel({
    super.key,
    required this.metrics,
    this.title = 'Metrics',
  });

  final Metrics metrics;

  /// What the box calls itself. Defaulted, unlike `ShellPage.title` — that one
  /// refuses a fallback because a plausible one ships somebody's product name,
  /// and this one names no product.
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: scheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              // The knob region is a fixed 380 wide, so the title has to yield
              // rather than overflow when the text grows — a larger
              // accessibility text scale, or a translation, will do it.
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final reading in metrics.readings) ...[
            _Row(reading: reading),
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${_age(metrics.lastUpdate)}',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.reading});

  final Reading reading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = _ink(reading.severity, scheme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          if (reading.icon != null) ...[
            Icon(reading.icon, color: ink, size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reading.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: ink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (reading.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    reading.subtitle!,
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            reading.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// The same readings as one line, for where there is no room for the panel.
///
/// **Ink on a bordered surface, like the panel, rather than white on a filled
/// severity colour.** The filled form is what this was, and it carried the
/// panel's own bug in miniature: a ground chosen for one brightness. The label
/// of every reading is in the tooltip, because a bare value on a strip says
/// what it is worth but not what it is.
class MetricsChip extends StatelessWidget {
  const MetricsChip({super.key, required this.metrics});

  final Metrics metrics;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final severity = metrics.severity;
    final ink = _ink(severity, scheme);

    return Tooltip(
      message: [for (final r in metrics.readings) '${r.label}: ${r.value}']
          .join('\n'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(severity), size: 14, color: ink),
            for (final reading in metrics.readings) ...[
              const SizedBox(width: 8),
              Text(
                reading.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _ink(reading.severity, scheme),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// How long ago, in the coarsest unit that still says something.
String _age(DateTime taken) {
  final diff = DateTime.now().difference(taken);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  return '${taken.hour}:${taken.minute.toString().padLeft(2, '0')}';
}
