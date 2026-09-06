// A full page, pointed at rather than absorbed.
//
// It has its own `Scaffold` and its own app bar, so putting it inside the
// shell's stage would mean taking it apart. `RouteDestination` opens it on its
// own route instead — which is the whole reason that type is sealed.

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About this example')),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            'What you are looking at',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'The shell around this page is flutter_example_template. It knows '
            'nothing about action bars: it was handed a set of destinations and '
            'a settings host, and everything on screen follows from those.\n\n'
            'The package being demonstrated is in lib/subject/, and it in turn '
            'knows nothing about the shell. Neither half names the other except '
            'through the ports, and two test suites hold both halves to that.',
            style: TextStyle(color: scheme.onSurfaceVariant, height: 1.6),
          ),
        ],
      ),
    );
  }
}
