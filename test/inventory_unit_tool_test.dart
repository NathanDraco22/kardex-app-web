import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/tools/inventory_unit_tool.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('InventoryUnitTool.buildOptions', () {
    test('incluye la unidad base y las unidades extra', () {
      final options = InventoryUnitTool.buildOptions(
        baseUnitName: 'Unidad',
        extraUnits: const [
          ExtraUnit(name: 'Media caja', conversionFactor: 15),
          ExtraUnit(name: 'Caja', conversionFactor: 30),
        ],
      );

      expect(options, hasLength(3));
      expect(options[0].index, 0);
      expect(options[0].name, 'Unidad');
      expect(options[0].factor, 1);
      expect(options[0].isBase, isTrue);
      expect(options[1].name, 'Media caja');
      expect(options[1].factor, 15);
      expect(options[2].name, 'Caja');
      expect(options[2].factor, 30);
    });

    test('normaliza factores inválidos a 1', () {
      final options = InventoryUnitTool.buildOptions(
        baseUnitName: 'Libra',
        extraUnits: const [
          ExtraUnit(name: 'Caja', conversionFactor: 0),
        ],
      );

      expect(options[1].factor, 1);
    });
  });

  group('InventoryUnitTool.resolveDefault', () {
    final options = InventoryUnitTool.buildOptions(
      baseUnitName: 'Unidad',
      extraUnits: const [
        ExtraUnit(name: 'Media caja', conversionFactor: 15),
        ExtraUnit(name: 'Caja', conversionFactor: 30),
      ],
    );

    test('usa la unidad base cuando el índice es 0', () {
      final selected = InventoryUnitTool.resolveDefault(
        options: options,
        defaultUnitIndex: 0,
      );

      expect(selected.name, 'Unidad');
      expect(selected.factor, 1);
    });

    test('usa la unidad extra configurada', () {
      final selected = InventoryUnitTool.resolveDefault(
        options: options,
        defaultUnitIndex: 2,
      );

      expect(selected.name, 'Caja');
      expect(selected.factor, 30);
    });

    test('cae en la unidad base si el índice está fuera de rango', () {
      final selected = InventoryUnitTool.resolveDefault(
        options: options,
        defaultUnitIndex: 99,
      );

      expect(selected.name, 'Unidad');
    });
  });

  group('InventoryUnitTool.allowsDecimals', () {
    final options = InventoryUnitTool.buildOptions(
      baseUnitName: 'Unidad',
      extraUnits: const [
        ExtraUnit(name: 'Media caja', conversionFactor: 15),
        ExtraUnit(name: 'Caja', conversionFactor: 30),
      ],
    );

    test('la unidad base no permite decimales', () {
      expect(
        InventoryUnitTool.allowsDecimals(option: options[0], defaultUnitIndex: 2),
        isFalse,
      );
    });

    test('la unidad por defecto y las inferiores permiten decimales', () {
      expect(
        InventoryUnitTool.allowsDecimals(option: options[1], defaultUnitIndex: 2),
        isTrue,
      );
      expect(
        InventoryUnitTool.allowsDecimals(option: options[2], defaultUnitIndex: 2),
        isTrue,
      );
    });

    test('las unidades superiores a la de defecto no permiten decimales', () {
      expect(
        InventoryUnitTool.allowsDecimals(option: options[2], defaultUnitIndex: 1),
        isFalse,
      );
    });
  });

  group('InventoryUnitTool conversiones', () {
    test('convierte cantidad display a base', () {
      expect(InventoryUnitTool.toBaseQuantity(1.5, 4), 6);
      expect(InventoryUnitTool.toBaseQuantity(2, 30), 60);
      expect(InventoryUnitTool.toBaseQuantity(0.5, 30), 15);
    });

    test('convierte costo display a base y viceversa', () {
      expect(InventoryUnitTool.toBaseCost(1000, 16), 63);
      expect(InventoryUnitTool.toDisplayCost(100, 16), 1600);
    });

    test('convierte costo entre unidades', () {
      expect(
        InventoryUnitTool.convertDisplayCost(
          displayCostCents: 3000,
          oldFactor: 30,
          newFactor: 15,
        ),
        1500,
      );
    });

    test('convierte cantidades entre unidades conservando la base', () {
      expect(
        InventoryUnitTool.convertDisplayQuantity(
          displayQuantity: 2,
          oldFactor: 30,
          newFactor: 1,
          newUnitIndex: 0,
          defaultUnitIndex: 2,
        ),
        60,
      );

      expect(
        InventoryUnitTool.convertDisplayQuantity(
          displayQuantity: 1,
          oldFactor: 30,
          newFactor: 15,
          newUnitIndex: 1,
          defaultUnitIndex: 2,
        ),
        2,
      );
    });

    test('devuelve null cuando la unidad superior no representa la cantidad', () {
      expect(
        InventoryUnitTool.convertDisplayQuantity(
          displayQuantity: 1,
          oldFactor: 15,
          newFactor: 30,
          newUnitIndex: 2,
          defaultUnitIndex: 1,
        ),
        isNull,
      );
    });

    test('formatea stock y dinero', () {
      expect(InventoryUnitTool.formatBaseStock(60, 30), '2');
      expect(InventoryUnitTool.formatBaseStock(15, 30), '0.5');
      expect(InventoryUnitTool.formatMoney(3000), '30.00');
    });
  });
}
