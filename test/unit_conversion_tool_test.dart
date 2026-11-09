import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('UnitConversionTool.convertDisplayQuantity', () {
    test('convierte unidad base a unidad comercial', () {
      expect(
        UnitConversionTool.convertDisplayQuantity(500, 1, 454),
        closeTo(1.1013, 0.0001),
      );
    });

    test('convierte unidad comercial a unidad base', () {
      expect(
        UnitConversionTool.convertDisplayQuantity(0.5, 454, 1),
        closeTo(227, 0.0001),
      );
    });

    test('convierte libra a kilogramo conservando la cantidad física', () {
      expect(
        UnitConversionTool.convertDisplayQuantity(10, 454, 1000),
        closeTo(4.54, 0.0001),
      );
    });

    test('un factor cero se protege como 1', () {
      expect(UnitConversionTool.ensureSafeFactor(0), 1);
      expect(UnitConversionTool.convertDisplayQuantity(10, 1, 0), 10);
    });
  });

  group('UnitConversionTool.convertDisplayQuantityToInteger', () {
    test('devuelve entero cuando la conversión es exacta', () {
      expect(
        UnitConversionTool.convertDisplayQuantityToInteger(10, 454, 454),
        10,
      );
      expect(
        UnitConversionTool.convertDisplayQuantityToInteger(1000, 1, 1000),
        1,
      );
    });

    test('devuelve null cuando la conversión no es entera', () {
      expect(
        UnitConversionTool.convertDisplayQuantityToInteger(10, 454, 1000),
        isNull,
      );
      expect(
        UnitConversionTool.convertDisplayQuantityToInteger(500, 1, 1000),
        isNull,
      );
    });

    test('cantidad cero se mantiene en cero', () {
      expect(
        UnitConversionTool.convertDisplayQuantityToInteger(0, 454, 1000),
        0,
      );
    });
  });

  group('UnitConversionTool.minimumStep', () {
    test('equivale a una unidad base para cada factor', () {
      expect(UnitConversionTool.minimumStep(1), 1);
      expect(UnitConversionTool.minimumStep(2), 0.5);
      expect(UnitConversionTool.minimumStep(4), 0.25);
      expect(UnitConversionTool.minimumStep(30), closeTo(1 / 30, 1e-12));
    });

    test('protege factores inválidos como 1', () {
      expect(UnitConversionTool.minimumStep(0), 1);
    });
  });

  group('UnitConversionTool.formatQuantity', () {
    test('conserva decimales de pasos pequeños cuando se solicita', () {
      expect(
        UnitConversionTool.formatQuantity(0.0025, maxDecimals: 4),
        '0.0025',
      );
    });

    test('mantiene tres decimales por defecto', () {
      expect(UnitConversionTool.formatQuantity(0.0333333333), '0.033');
    });
  });

  group('UnitConversionTool.convertUnitCost', () {
    test('convierte costo comercial a costo base', () {
      expect(UnitConversionTool.convertUnitCost(1800, 454, 1), 4);
    });

    test('convierte costo base a costo comercial', () {
      expect(UnitConversionTool.convertUnitCost(4, 1, 454), 1816);
    });

    test('convierte costo de libra a kilogramo', () {
      expect(UnitConversionTool.convertUnitCost(1800, 454, 1000), 3965);
    });
  });
}
