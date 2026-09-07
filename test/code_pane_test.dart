import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_example_template/flutter_example_template.dart';

class _Bundle extends CachingAssetBundle {
  _Bundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async {
    final text = _files[key];
    if (text == null) throw FlutterError('no asset for $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

void main() {
  const path = 'lib/recipes/basic_action_bar.dart';
  const source = "import 'package:flutter/material.dart';\n"
      '\n'
      'class BasicActionBar extends StatelessWidget {\n'
      "  static const label = 'x \${1 + 1} y';\n"
      '}\n';

  testWidgets('the pane draws the bytes it was handed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodePane(assetPath: path, bundle: _Bundle({path: source})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining(path), findsWidgets, reason: 'the path bar');
    expect(
      find.textContaining('BasicActionBar'),
      findsWidgets,
      reason: 'the source itself, which is the whole point of the pane',
    );
  });

  testWidgets('an unreadable asset says so rather than drawing nothing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CodePane(assetPath: path, bundle: _Bundle(const {})),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not read'), findsOneWidget);
  });
}
