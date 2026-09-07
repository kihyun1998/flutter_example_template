import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

void main() {
  testWidgets('the bundled recipe reaches the pane through the real bundle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CodePane(assetPath: 'lib/recipes/basic_action_bar.dart'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('BasicActionBar'),
      findsWidgets,
      reason: 'the asset key is declared in pubspec.yaml and should resolve',
    );
  });
}
