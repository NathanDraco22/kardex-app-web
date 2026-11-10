import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/widgets/elements/price_level_sync_controller.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('PriceLevelSyncController', () {
    test('inicializa precios base y equivalentes por unidad', () {
      final controller = PriceLevelSyncController(
        initialPrices: [1000, 2000, 0, 0],
        extraUnits: const [
          ExtraUnit(name: 'Caja', conversionFactor: 12),
        ],
      );

      expect(controller.prices, [1000, 2000, 0, 0]);
      expect(controller.factor, 12);
      expect(controller.baseControllers[0].text, '10.00');
      expect(controller.baseControllers[1].text, '20.00');
      expect(controller.extraControllers[0].text, '120.00');
      expect(controller.extraControllers[1].text, '240.00');
      expect(controller.extraControllers[2].text, '0.00');

      controller.dispose();
    });

    test('actualiza el equivalente al cambiar el precio base', () {
      final controller = PriceLevelSyncController(
        initialPrices: [1000, 0, 0, 0],
        extraUnits: const [
          ExtraUnit(name: 'Caja', conversionFactor: 12),
        ],
      );

      controller.onBaseChanged(0, '15.50');

      expect(controller.prices[0], 1550);
      expect(controller.extraControllers[0].text, '186.00');

      controller.dispose();
    });

    test('actualiza el precio base al cambiar el equivalente', () {
      final controller = PriceLevelSyncController(
        initialPrices: [1000, 0, 0, 0],
        extraUnits: const [
          ExtraUnit(name: 'Caja', conversionFactor: 12),
        ],
      );

      controller.onExtraChanged(0, '24.00');

      expect(controller.prices[0], 200);
      expect(controller.baseControllers[0].text, '2.00');

      controller.dispose();
    });

    test('recalcula equivalentes al cambiar de unidad', () {
      const caja = ExtraUnit(name: 'Caja', conversionFactor: 12);
      const docena = ExtraUnit(name: 'Docena', conversionFactor: 6);
      final controller = PriceLevelSyncController(
        initialPrices: [1200, 0, 0, 0],
        extraUnits: const [caja, docena],
      );

      controller.selectUnit(docena);

      expect(controller.factor, 6);
      expect(controller.extraControllers[0].text, '72.00');

      controller.dispose();
    });

    test('aplica el precio sugerido sobre el primer nivel', () {
      final controller = PriceLevelSyncController(
        initialPrices: [1000, 2000, 3000, 4000],
        extraUnits: const [
          ExtraUnit(name: 'Caja', conversionFactor: 12),
        ],
      );

      controller.applySuggestedBasePrice(2500);

      expect(controller.prices, [2500, 2000, 3000, 4000]);
      expect(controller.baseControllers[0].text, '25.00');
      expect(controller.extraControllers[0].text, '300.00');

      controller.dispose();
    });

    test('conserva la unidad seleccionada si sigue existiendo', () {
      const caja = ExtraUnit(name: 'Caja', conversionFactor: 12);
      final controller = PriceLevelSyncController(
        initialPrices: [1000, 0, 0, 0],
        extraUnits: const [caja],
      );

      controller.updateExtraUnits(const [
        ExtraUnit(name: 'Caja', conversionFactor: 12),
        ExtraUnit(name: 'Docena', conversionFactor: 6),
      ]);

      expect(controller.selectedUnit?.name, 'Caja');
      expect(controller.factor, 12);

      controller.dispose();
    });

    test('usa la primera unidad si la seleccionada desaparece', () {
      const caja = ExtraUnit(name: 'Caja', conversionFactor: 12);
      const docena = ExtraUnit(name: 'Docena', conversionFactor: 6);
      final controller = PriceLevelSyncController(
        initialPrices: [1200, 0, 0, 0],
        extraUnits: const [caja, docena],
      );

      controller.selectUnit(docena);
      controller.updateExtraUnits(const [caja]);

      expect(controller.selectedUnit?.name, 'Caja');
      expect(controller.factor, 12);
      expect(controller.extraControllers[0].text, '144.00');

      controller.dispose();
    });

    test('deja la unidad en null cuando no hay unidades extra', () {
      final controller = PriceLevelSyncController(
        initialPrices: [1000, 0, 0, 0],
        extraUnits: const [],
      );

      expect(controller.selectedUnit, isNull);
      expect(controller.hasExtraUnit, isFalse);
      expect(controller.extraControllers[0].text, '');

      controller.updateExtraUnits(const []);

      expect(controller.selectedUnit, isNull);
      expect(controller.extraControllers[0].text, '');

      controller.dispose();
    });
  });
}
