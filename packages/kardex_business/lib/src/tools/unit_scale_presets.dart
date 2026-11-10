import '../domain/models/product/product_model.dart';
import '../domain/models/unit_scale/unit_scale_model.dart';

/// Catálogo de plantillas y presets predefinidos de escalas de unidades
/// para acelerar la creación de productos sin configuración manual repetitiva.
class UnitScalePresets {
  const UnitScalePresets._();

  /// Las escalas por defecto viven en el backend
  /// (`create_default_unit_scales.py`) y se exponen por
  /// `GET /api/v1/unit-scales`. El frontend no mantiene una lista duplicada
  /// de presets estándar; el selector consume las escalas del repositorio.
  static const List<BaseUnitScale> standardPresets = <BaseUnitScale>[];

  static String _packName(String packName) {
    final trimmed = packName.trim();
    return trimmed.isEmpty ? 'Caja' : trimmed;
  }

  static String _packLabel(String packName, int unitsPerPack) {
    final pack = _packName(packName);
    if (pack.toLowerCase() == 'docena') return 'Docena';
    return '$pack x$unitsPerPack';
  }

  /// Genera una escala de empaque fraccionado para [unitsPerPack] unidades.
  ///
  /// Si el tamaño es múltiplo de 4, la base es el cuarto de empaque (factor 4);
  /// si solo es par, la base es la media parte (factor 2). Los empaques
  /// impares no tienen fracción exacta y devuelven `null`.
  static BaseUnitScale? buildFractionPack({
    required String packName,
    required int unitsPerPack,
  }) {
    if (unitsPerPack <= 1) return null;

    final label = _packLabel(packName, unitsPerPack);

    if (unitsPerPack % 4 == 0) {
      return BaseUnitScale(
        name: '$label - Fracción',
        scaleType: UnitScaleType.fractionPack,
        baseUnit: 'Cuarto de $label (${unitsPerPack ~/ 4} u)',
        units: [
          ExtraUnit(
            name: 'Media $label (${unitsPerPack ~/ 2} u)',
            conversionFactor: 2,
          ),
          ExtraUnit(name: '$label ($unitsPerPack u)', conversionFactor: 4),
        ],
        defaultUnitIndex: 2,
        wholesaleUnitIndex: 2,
      );
    }

    if (unitsPerPack % 2 == 0) {
      return BaseUnitScale(
        name: '$label - Fracción',
        scaleType: UnitScaleType.fractionPack,
        baseUnit: 'Media $label (${unitsPerPack ~/ 2} u)',
        units: [
          ExtraUnit(name: '$label ($unitsPerPack u)', conversionFactor: 2),
        ],
        defaultUnitIndex: 1,
        wholesaleUnitIndex: 1,
      );
    }

    return null;
  }

  /// Genera una escala de empaque con venta por unidad.
  ///
  /// La base es `Unidad`; si el empaque es par se agrega la media parte y
  /// siempre se agrega el empaque completo con factor [unitsPerPack].
  static BaseUnitScale? buildPack({
    required String packName,
    required int unitsPerPack,
  }) {
    if (unitsPerPack <= 1) return null;

    final label = _packLabel(packName, unitsPerPack);
    final halfFactor = unitsPerPack ~/ 2;
    final units = <ExtraUnit>[
      if (unitsPerPack % 2 == 0 && halfFactor > 1)
        ExtraUnit(
          name: 'Media $label ($halfFactor u)',
          conversionFactor: halfFactor,
        ),
      ExtraUnit(
        name: '$label ($unitsPerPack u)',
        conversionFactor: unitsPerPack,
      ),
    ];

    return BaseUnitScale(
      name: '$label - Unidad',
      scaleType: UnitScaleType.pack,
      baseUnit: 'Unidad',
      units: units,
      defaultUnitIndex: units.length,
      wholesaleUnitIndex: units.length,
    );
  }
}
