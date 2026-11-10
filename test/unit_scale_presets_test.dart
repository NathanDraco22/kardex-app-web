import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('UnitScalePresets.buildFractionPack', () {
    test('Caja x30 usa media caja como base', () {
      final scale = UnitScalePresets.buildFractionPack(
        packName: 'Caja',
        unitsPerPack: 30,
      );

      expect(scale, isNotNull);
      expect(scale!.scaleType, UnitScaleType.fractionPack);
      expect(scale.name, 'Caja x30 - Fracción');
      expect(scale.baseUnit, '1/2 Caja x30 (15 u)');
      expect(scale.units, hasLength(1));
      expect(scale.units.single.name, 'Caja x30 (30 u)');
      expect(scale.units.single.conversionFactor, 2);
      expect(scale.defaultUnitIndex, 1);
    });

    test('Caja x12 usa cuarto de caja como base', () {
      final scale = UnitScalePresets.buildFractionPack(
        packName: 'Caja',
        unitsPerPack: 12,
      );

      expect(scale, isNotNull);
      expect(scale!.baseUnit, '1/4 Caja x12 (3 u)');
      expect(scale.units.map((u) => u.name), [
        '1/2 Caja x12 (6 u)',
        'Caja x12 (12 u)',
      ]);
      expect(scale.units.map((u) => u.conversionFactor), [2, 4]);
      expect(scale.defaultUnitIndex, 2);
    });

    test('Docena usa nombres sin el x12 redundante', () {
      final scale = UnitScalePresets.buildFractionPack(
        packName: 'Docena',
        unitsPerPack: 12,
      );

      expect(scale, isNotNull);
      expect(scale!.name, 'Docena - Fracción');
      expect(scale.baseUnit, '1/4 Docena (3 u)');
      expect(scale.units.map((u) => u.name), [
        '1/2 Docena (6 u)',
        'Docena (12 u)',
      ]);
    });

    test('un empaque impar no se puede fraccionar', () {
      expect(
        UnitScalePresets.buildFractionPack(
          packName: 'Caja',
          unitsPerPack: 15,
        ),
        isNull,
      );
    });
  });

  group('UnitScalePresets.buildPack', () {
    test('Caja x30 permite vender por unidad y por caja', () {
      final scale = UnitScalePresets.buildPack(
        packName: 'Caja',
        unitsPerPack: 30,
      );

      expect(scale, isNotNull);
      expect(scale!.scaleType, UnitScaleType.pack);
      expect(scale.baseUnit, 'Unidad');
      expect(scale.units.map((u) => u.name), [
        '1/2 Caja x30 (15 u)',
        'Caja x30 (30 u)',
      ]);
      expect(scale.units.map((u) => u.conversionFactor), [15, 30]);
      expect(scale.defaultUnitIndex, 2);
    });

    test('Caja x2 no genera una media con factor 1', () {
      final scale = UnitScalePresets.buildPack(
        packName: 'Caja',
        unitsPerPack: 2,
      );

      expect(scale, isNotNull);
      expect(scale!.units, hasLength(1));
      expect(scale.units.single.name, 'Caja x2 (2 u)');
      expect(scale.units.single.conversionFactor, 2);
    });
  });
}
