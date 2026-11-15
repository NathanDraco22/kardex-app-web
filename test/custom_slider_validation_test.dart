import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

void main() {
  testWidgets(
    'CustomSlider muestra error de Form y regresa al inicio cuando validator falla, permitiendo reintentar tras llenar el campo',
    (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();
      var submitCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: controller,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el efectivo contado en caja';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomSlider(
                        hintText: 'Desliza para Cerrar Turno',
                        hintIcon: Icons.lock_outline_rounded,
                        sliderColor: Colors.red,
                        sliderText: 'Cerrar',
                        validator: () => formKey.currentState?.validate() ?? false,
                        onSubmit: () {
                          submitCount++;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Posición inicial del botón "Cerrar"
      final initialLeft = tester.getTopLeft(find.text('Cerrar')).dx;

      // Deslizar completamente hacia la derecha con el campo vacío
      await tester.drag(find.text('Cerrar'), const Offset(350, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Se debe mostrar el error en el TextFormField y NO ejecutar onSubmit
      expect(find.text('Ingresa el efectivo contado en caja'), findsOneWidget);
      expect(submitCount, 0);

      // El slider debe haber regresado a su posición inicial
      final resetLeft = tester.getTopLeft(find.text('Cerrar')).dx;
      expect(resetLeft, closeTo(initialLeft, 1.0));

      // Llenar el campo y volver a deslizar
      await tester.enterText(find.byType(TextFormField), '150.00');
      await tester.pump();

      expect(find.text('Ingresa el efectivo contado en caja'), findsNothing);

      await tester.drag(find.text('Cerrar'), const Offset(350, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(submitCount, 1);
    },
  );
}
