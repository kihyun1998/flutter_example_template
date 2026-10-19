// A one-off probe for #27, run on CI's floor and latest legs, never merged.
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  const path = 'lib/recipes/long.dart';
  final long = List.generate(120, (i) => '// ${'x' * 200} $i').join('\n');

  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    for (final wrap in [false, true]) {
      testWidgets('PROBE $platform wrap=$wrap', (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        final primary = ScrollController();
        try {
          Widget pane = CodePane(assetPath: path, bundle: _Bundle({path: long}));
          if (wrap) {
            pane = PrimaryScrollController(controller: primary, child: pane);
          }
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: pane)));
          await tester.pumpAndSettle();
          // Drive the scrollbar: a drag on the view, so it paints and reads its controller.
          await tester.drag(find.byType(Scrollbar).first, const Offset(0, -200));
          await tester.pumpAndSettle();
          final err = tester.takeException();
          final ctx = tester.element(find.byType(Scrollbar).first);
          final pc = PrimaryScrollController.maybeOf(ctx);
          debugPrint(
            'PROBE $platform wrap=$wrap '
            'exception=${err == null ? 'none' : err.runtimeType} '
            'positions=${pc?.positions.length}',
          );
          expect(err, isNull);
          expect(pc!.positions.length, 1);
        } finally {
          debugDefaultTargetPlatformOverride = null;
          primary.dispose();
        }
      });
    }
  }
}
