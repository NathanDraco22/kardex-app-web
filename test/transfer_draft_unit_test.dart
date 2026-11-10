import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/core/transfer_draft_manager.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  const baseUnitName = '1/4 Libra';
  const defaultExtras = [
    TransferDraftUnitOption(name: 'Libra', factor: 4),
    TransferDraftUnitOption(name: 'Arroba (25 lb)', factor: 100),
    TransferDraftUnitOption(name: 'Quintal (100 lb)', factor: 400),
  ];

  TransferDraftUnitResolution resolve({
    int version = 3,
    int savedQuantity = 0,
    int savedUnitaryCost = 0,
    int? savedUnitIndex,
    int? savedFactor,
    String? savedUnitName,
    String? savedBaseUnitName = baseUnitName,
    String productBaseUnitName = baseUnitName,
    int productDefaultUnitIndex = 1,
    List<TransferDraftUnitOption> productExtraUnits = defaultExtras,
    int averageCost = 100,
  }) {
    return TransferDraftUnitResolver.resolve(
      version: version,
      savedQuantity: savedQuantity,
      savedUnitaryCost: savedUnitaryCost,
      savedUnitIndex: savedUnitIndex,
      savedFactor: savedFactor,
      savedUnitName: savedUnitName,
      savedBaseUnitName: savedBaseUnitName,
      productBaseUnitName: productBaseUnitName,
      productDefaultUnitIndex: productDefaultUnitIndex,
      productExtraUnits: productExtraUnits,
      averageCost: averageCost,
    );
  }

  group('TransferDraftUnitResolver', () {
    test('v2 con factor 4: 4 display = 16 base y costo averageCost * 4', () {
      final result = resolve(
        version: 2,
        savedQuantity: 4,
        savedUnitIndex: 1,
        savedFactor: 4,
        savedUnitName: 'Libra',
        savedBaseUnitName: null,
      );

      expect(result.quantity, 4);
      expect(result.baseQuantity, 16);
      expect(result.unitaryCost, 400);
      expect(result.selectedUnitIndex, 1);
      expect(result.selectedUnitName, 'Libra');
      expect(result.needsReview, isFalse);
    });

    test('v2 con unidad eliminada: restaura base, conserva cantidad y costo base', () {
      final result = resolve(
        version: 2,
        savedQuantity: 1,
        savedUnitIndex: 2,
        savedFactor: 100,
        savedUnitName: 'Arroba (25 lb)',
        savedBaseUnitName: null,
        productExtraUnits: const [
          TransferDraftUnitOption(name: 'Libra', factor: 4),
        ],
      );

      expect(result.selectedUnitIndex, 0);
      expect(result.selectedUnitName, baseUnitName);
      expect(result.baseQuantity, 100);
      expect(result.quantity, 100);
      expect(result.unitaryCost, 100);
      expect(result.needsReview, isTrue);
      expect(result.reviewReasons.join(' '), contains('ya no existe'));
    });

    test('v1 sin factor: infiere defaultUnitIndex, escala el costo y marca review', () {
      final result = resolve(
        version: 1,
        savedQuantity: 8,
        savedUnitaryCost: 100,
      );

      expect(result.selectedUnitIndex, 1);
      expect(result.selectedUnitName, 'Libra');
      expect(result.baseQuantity, 8);
      expect(result.quantity, 2);
      expect(result.unitaryCost, 400);
      expect(result.needsReview, isTrue);
    });

    test('cambio de baseUnitName: infiere la unidad por defecto y marca review', () {
      final result = resolve(
        savedQuantity: 2,
        savedUnitIndex: 1,
        savedFactor: 4,
        savedUnitName: 'Libra',
        savedBaseUnitName: '1/4 Libra',
        productBaseUnitName: 'Unidad',
        productExtraUnits: const [
          TransferDraftUnitOption(name: 'Libra', factor: 4),
        ],
      );

      expect(result.selectedUnitIndex, 1);
      expect(result.selectedUnitName, 'Libra');
      expect(result.quantity, 2);
      expect(result.baseQuantity, 8);
      expect(result.unitaryCost, 400);
      expect(result.needsReview, isTrue);
      expect(result.reviewReasons.join(' '), contains('unidad base'));
    });

    test('v2 en índice 0: detecta cambio de base por selectedUnitName', () {
      final result = resolve(
        version: 2,
        savedQuantity: 8,
        savedUnitIndex: 0,
        savedFactor: 1,
        savedUnitName: '1/4 Libra',
        savedBaseUnitName: null,
        productBaseUnitName: 'Unidad',
        productDefaultUnitIndex: 0,
        productExtraUnits: const [],
      );

      expect(result.selectedUnitIndex, 0);
      expect(result.selectedUnitName, 'Unidad');
      expect(result.quantity, 8);
      expect(result.baseQuantity, 8);
      expect(result.unitaryCost, 100);
      expect(result.needsReview, isTrue);
    });

    test('sin averageCost conserva el costo comercial y marca review', () {
      final result = resolve(
        savedQuantity: 4,
        savedUnitaryCost: 400,
        savedUnitIndex: 1,
        savedFactor: 4,
        savedUnitName: 'Libra',
        averageCost: 0,
      );

      expect(result.quantity, 4);
      expect(result.unitaryCost, 400);
      expect(result.needsReview, isTrue);
      expect(result.reviewReasons.join(' '), contains('costo promedio'));
    });

    test('v1 sin averageCost convierte el costo base a la unidad inferida', () {
      final result = resolve(
        version: 1,
        savedQuantity: 8,
        savedUnitaryCost: 100,
        averageCost: 0,
      );

      expect(result.quantity, 2);
      expect(result.unitaryCost, 400);
      expect(result.needsReview, isTrue);
    });
  });

  group('Display de transferencia', () {
    test('1 Quintal se muestra como 1 Quintal', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 400,
        conversionFactor: 400,
        selectedUnitName: 'Quintal (100 lb)',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '1');
      expect(display.unitName, 'Quintal (100 lb)');
      expect(display.usedStandardFallback, isFalse);
    });

    test('1.5 Quintal se muestra como 150 Libra', () {
      final display = UnitDisplayFormatter.formatUnitQuantity(
        baseQuantity: 600,
        conversionFactor: 400,
        selectedUnitName: 'Quintal (100 lb)',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
      );

      expect(display.quantityText, '150');
      expect(display.unitName, 'Libra');
      expect(display.usedStandardFallback, isTrue);
    });

    test('TransferItem usa la metadata y calcula el costo comercial', () {
      final item = TransferItem(
        id: 'product-1',
        name: 'Producto',
        unitName: 'Quintal (100 lb)',
        brandName: 'Marca',
        quantity: 600,
        cost: 100,
        conversionFactor: 400,
        selectedUnitName: 'Quintal (100 lb)',
        standardUnitName: 'Libra',
        standardUnitFactor: 4,
        salePrice: 0,
        salePrice2: 0,
        salePrice3: 0,
        salePrice4: 0,
      );

      expect(item.formattedDisplayQuantity, '150');
      expect(item.displayUnitName, 'Libra');
      expect(item.displayUnitFactor, 4);
      expect(item.displayUnitCost, 400);

      final restored = TransferItem.fromJson(item.toJson());
      expect(restored.selectedUnitName, 'Quintal (100 lb)');
      expect(restored.standardUnitName, 'Libra');
      expect(restored.standardUnitFactor, 4);
    });
  });
}
