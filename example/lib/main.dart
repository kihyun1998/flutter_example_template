// The only file in a consumer's example that has to know this shell exists.
//
// Everything the shell draws arrives through the ports: the destinations, and
// through one of them a settings host. Nothing here says what an action bar is.

import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

import 'gallery/destinations.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _theme = ExampleThemeController();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scope sits above the app so `ThemeModeButton`, which lives in the
    // shell's app bar, can find it.
    return ExampleThemeScope(
      controller: _theme,
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) => MaterialApp(
          title: 'Adaptive Action Bar',
          debugShowCheckedModeBanner: false,
          theme: exampleTheme(Brightness.light),
          darkTheme: exampleTheme(Brightness.dark),
          themeMode: _theme.mode,
          // Deliberately not defaulted by the shell: a plausible fallback title
          // is a shell that ships someone else's product name.
          home: ShellPage(
            title: 'Adaptive Action Bar',
            createDestinations: ActionBarDestinations.new,
          ),
        ),
      ),
    );
  }
}
