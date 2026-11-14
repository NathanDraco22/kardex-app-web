import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/adaptive_viewer.dart';

void main() {
  Widget buildTestApp({required Size size, required Widget child}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(home: child),
    );
  }

  testWidgets(
    'showAdaptiveViewer abre modal bottom sheet de 600px y 95% de alto en escritorio',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1280, 800),
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showAdaptiveViewer(
                    context: context,
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Contenido Visor')),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Contenido Visor'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);

      final sheetSize = tester.getSize(find.byType(ClipRRect));
      expect(sheetSize.width, 600);
      expect(sheetSize.height, closeTo(800 * 0.95, 0.1));

      // Tocar fuera del modal (en el barrier) no debe cerrarlo.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('Contenido Visor'), findsOneWidget);
    },
  );

  testWidgets(
    'showAdaptiveViewer abre ruta a pantalla completa en móvil/tablet',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestApp(
          size: const Size(400, 800),
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showAdaptiveViewer(
                    context: context,
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Contenido Visor Móvil')),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Contenido Visor Móvil'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);

      final viewerSize = tester.getSize(find.text('Contenido Visor Móvil'));
      expect(viewerSize.width, lessThanOrEqualTo(400));
    },
  );
}
