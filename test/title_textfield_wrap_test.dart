import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

void main() {
  testWidgets('el título largo no desborda en ancho angosto', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              child: TitleTextField(
                title: 'Por 1/2 Caja x30 (15 u) (C\$):',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
