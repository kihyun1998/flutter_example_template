// A bar in a card, at whatever width it is given.
//
// Self-contained on purpose: paste this file into an app that has the package
// and it runs. It imports Flutter and the package being demonstrated, and
// nothing else — no gallery, no shell. That is a rule, and
// `test/pasteable_seam_test.dart` holds it.

import 'package:flutter/material.dart';

import '../subject/adaptive_action_bar.dart';

class BasicActionBar extends StatelessWidget {
  const BasicActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: AdaptiveActionBar(
            actions: demoActions.take(5).toList(),
            onPressed: (action) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(action.label),
                duration: const Duration(milliseconds: 600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
