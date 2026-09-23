/// The stage region at its own size, at 1:1.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'preview_frame.dart';

/// Lays [child] out in all the room it is given, less the caption, and never
/// scales it.
class PreviewRoom extends StatelessWidget {
  const PreviewRoom({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final captionHeight = math.min(
          PreviewFrame.labelHeight,
          constraints.maxHeight,
        );
        final size = Size(
          constraints.maxWidth,
          constraints.maxHeight - captionHeight,
        );

        return Column(
          children: [
            SizedBox.fromSize(
              size: size,
              child: ColoredBox(
                color: scheme.surface,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: size,
                    padding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                  ),
                  child: child,
                ),
              ),
            ),
            SizedBox(
              height: captionHeight,
              child: Center(
                child: Text(
                  PreviewFrame.labelFor(size, 1.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
