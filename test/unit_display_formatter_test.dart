import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('UnitDisplayFormatter.formatUnitQuantity', () {
    test('unidad estándar con fracciones: 6 base = 1.5 Libra', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 6,
        conversionFactor: 4,
        selectedUnitName: 'Libra',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '1.5');
      expect(display.unitName, 'Libra');
      expect(display.usedStandardFallback, isFalse);
    });

    test('unidad superior divisible: 400 base = 1 Quintal', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 400,
        conversionFactor: 400,
        selectedUnitName: 'Quintal',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '1');
      expect(display.unitName, 'Quintal');
      expect(display.usedStandardFallback, isFalse);
    });

    test('unidad superior no divisible cae a la estándar: 600 base = 150 Libra', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 600,
        conversionFactor: 400,
        selectedUnitName: 'Quintal',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '150');
      expect(display.unitName, 'Libra');
      expect(display.usedStandardFallback, isTrue);
    });

    test('Arroba no divisible cae a Libra: 50 base = 12.5 Libra', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 50,
        conversionFactor: 100,
        selectedUnitName: 'Arroba',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '12.5');
      expect(display.unitName, 'Libra');
      expect(display.usedStandardFallback, isTrue);
    });

    test('Caja x30 estándar: 30 base = 1 Caja x30', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 30,
        conversionFactor: 30,
        selectedUnitName: 'Caja x30',
        standardUnitName: 'Caja x30',
        standardUnitFactor: 30,
      );

      expect(display.quantityText, '1');
      expect(display.unitName, 'Caja x30');
      expect(display.usedStandardFallback, isFalse);
    });

    test('metadata nula usa el fallback decimal en la unidad seleccionada', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 1,
        conversionFactor: 400,
        selectedUnitName: 'Quintal',
      );

      expect(display.quantityText, '0.0025');
      expect(display.unitName, 'Quintal');
      expect(display.usedStandardFallback, isFalse);
    });

    test('cantidad base cero muestra 0 en la unidad seleccionada', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 0,
        conversionFactor: 400,
        selectedUnitName: 'Quintal',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '0');
      expect(display.unitName, 'Quintal');
      expect(display.usedStandardFallback, isFalse);
    });

    test('NumberFormatter.formatDisplayStock conserva precisión con factor 400', () {
      expect(NumberFormatter.formatDisplayStock(1, 400), '0.0025');
      expect(NumberFormatter.formatDisplayStock(2, 400), '0.005');
      expect(NumberFormatter.formatDisplayStock(399, 400), '0.9975');
    });
  });

  group('SaleItem metadata de unidad', () {
    SaleItem buildSaleItem({
      String? selectedUnitName,
      String? standardUnitName,
      int? standardUnitFactor,
      int quantity = 600,
      int conversionFactor = 400,
    }) => SaleItem(
      product: ProductItem(
        id: 'product-1',
        name: 'Producto',
        unitName: 'Quintal',
        brandName: 'Marca',
      ),
      selectedPrice: 1,
      quantity: quantity,
      cost: 10,
      price: 20,
      subTotal: quantity * 20,
      total: quantity * 20,
      conversionFactor: conversionFactor,
      selectedUnitName: selectedUnitName,
      standardUnitName: standardUnitName,
      standardUnitFactor: standardUnitFactor,
    );

    test('display usa unidad estándar cuando la superior no es divisible', () {
      final item = buildSaleItem(
        selectedUnitName: 'Quintal',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(item.formattedDisplayQuantity, '150');
      expect(item.displayUnitName, 'Libra');
      expect(item.displayUnitFactor, 4);
    });

    test('serializa y deserializa los nuevos campos', () {
      final item = buildSaleItem(
        selectedUnitName: 'Quintal',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      final json = item.toJson();
      expect(json['selectedUnitName'], 'Quintal');
      expect(json['standardUnitName'], 'Libra');
      expect(json['standardUnitFactor'], 4);

      final restored = SaleItem.fromJson(json);
      expect(restored.selectedUnitName, 'Quintal');
      expect(restored.standardUnitName, 'Libra');
      expect(restored.standardUnitFactor, 4);
    });

    test('omite los nuevos campos cuando son nulos', () {
      final json = buildSaleItem(quantity: 1, conversionFactor: 1).toJson();

      expect(json.containsKey('selectedUnitName'), isFalse);
      expect(json.containsKey('standardUnitName'), isFalse);
      expect(json.containsKey('standardUnitFactor'), isFalse);
    });
  });

  group('EntryItem metadata de unidad', () {
    EntryItem buildEntryItem({
      String? standardUnitName,
      int? standardUnitFactor,
      int quantity = 600,
    }) => EntryItem(
      productId: 'product-1',
      productName: 'Producto',
      cost: 10,
      quantity: quantity,
      conversionFactor: 400,
      unitName: 'Quintal',
      standardUnitName: standardUnitName,
      standardUnitFactor: standardUnitFactor,
    );

    test('display usa la unidad estándar con fracciones', () {
      final item = buildEntryItem(
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(item.formattedDisplayQuantity, '150');
      expect(item.displayUnitName, 'Libra');
    });

    test('serializa y deserializa los nuevos campos', () {
      final item = buildEntryItem(
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      final json = item.toJson();
      expect(json['standardUnitName'], 'Libra');
      expect(json['standardUnitFactor'], 4);

      final restored = EntryItem.fromJson(json);
      expect(restored.standardUnitName, 'Libra');
      expect(restored.standardUnitFactor, 4);
    });

    test('omite los nuevos campos cuando son nulos', () {
      final json = buildEntryItem().toJson();

      expect(json.containsKey('standardUnitName'), isFalse);
      expect(json.containsKey('standardUnitFactor'), isFalse);
    });
  });
}
