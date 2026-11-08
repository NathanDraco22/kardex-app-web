import '../domain/models/product/product_model.dart';
import '../domain/models/unit_scale/unit_scale_model.dart';

/// Catálogo de plantillas y presets predefinidos de escalas de unidades
/// para acelerar la creación de productos sin configuración manual repetitiva.
class UnitScalePresets {
  const UnitScalePresets._();

  static const List<BaseUnitScale> standardPresets = [
    BaseUnitScale(
      name: 'Peso (Libras / Kilogramos)',
      baseUnit: 'Gramos',
      units: [
        ExtraUnit(name: 'Libra', conversionFactor: 454),
        ExtraUnit(name: 'Kilogramo', conversionFactor: 1000),
      ],
      defaultUnitIndex: 1, // Libra
      wholesaleUnitIndex: 2, // Kilogramo
    ),
    BaseUnitScale(
      name: 'Peso Agrícola (Libras / Arrobas / Quintales)',
      baseUnit: 'Gramos',
      units: [
        ExtraUnit(name: 'Libra', conversionFactor: 454),
        ExtraUnit(name: 'Arroba (25 lb)', conversionFactor: 11350),
        ExtraUnit(name: 'Quintal (100 lb)', conversionFactor: 45400),
      ],
      defaultUnitIndex: 1, // Libra
      wholesaleUnitIndex: 3, // Quintal
    ),
    BaseUnitScale(
      name: 'Volumen y Líquidos (Litros / Galones)',
      baseUnit: 'Mililitros',
      units: [
        ExtraUnit(name: 'Litro', conversionFactor: 1000),
        ExtraUnit(name: 'Galón', conversionFactor: 3785),
      ],
      defaultUnitIndex: 1, // Litro
      wholesaleUnitIndex: 2, // Galón
    ),
    BaseUnitScale(
      name: 'Empaques y Cajas (Docenas / Cajas x24)',
      baseUnit: 'Unidades',
      units: [
        ExtraUnit(name: 'Media Docena', conversionFactor: 6),
        ExtraUnit(name: 'Docena', conversionFactor: 12),
        ExtraUnit(name: 'Caja x24', conversionFactor: 24),
      ],
      defaultUnitIndex: 0, // Unidades
      wholesaleUnitIndex: 3, // Caja x24
    ),
    BaseUnitScale(
      name: 'Longitud y Telas (Metros / Yardas)',
      baseUnit: 'Centímetros',
      units: [
        ExtraUnit(name: 'Yarda', conversionFactor: 91),
        ExtraUnit(name: 'Metro', conversionFactor: 100),
      ],
      defaultUnitIndex: 2, // Metro
      wholesaleUnitIndex: 2, // Metro
    ),
  ];
}
