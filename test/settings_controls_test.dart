import 'package:flutter/material.dart';
import 'package:flutter_example_template/flutter_example_template.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<int?>> _pumpDropdown(WidgetTester tester) async {
  final picked = <int?>[];
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: buildDropdownRow<int?>(
          id: 'size',
          label: 'Size',
          value: 2,
          items: const [null, 1, 2],
          itemLabel: (v) => v == null ? 'default' : '$v',
          onChanged: picked.add,
        ),
      ),
    ),
  );
  await tester.tap(find.text('2'));
  await tester.pumpAndSettle();
  return picked;
}

void main() {
  group('buildDropdownRow over a nullable type', () {
    testWidgets('picking the null item reports null', (tester) async {
      final picked = await _pumpDropdown(tester);
      await tester.tap(find.text('default').last);
      await tester.pumpAndSettle();
      expect(picked, [null]);
    });

    testWidgets('picking a value reports that value', (tester) async {
      final picked = await _pumpDropdown(tester);
      await tester.tap(find.text('1').last);
      await tester.pumpAndSettle();
      expect(picked, [1]);
    });

    testWidgets('closing the menu without picking reports nothing', (
      tester,
    ) async {
      final picked = await _pumpDropdown(tester);
      expect(find.text('default'), findsOneWidget);
      await tester.tapAt(const Offset(5, 590));
      await tester.pumpAndSettle();
      expect(find.text('default'), findsNothing);
      expect(picked, isEmpty);
    });
  });
}
