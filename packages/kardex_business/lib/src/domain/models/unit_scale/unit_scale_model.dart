import '../product/product_model.dart';

/// Tipo de escala de unidades.
///
/// El tipo vive solo en la escala/plantilla; el producto guarda su foto de
/// `unitName`, `extraUnits`, `defaultUnitIndex` y `wholesaleUnitIndex`.
enum UnitScaleType {
  weight('weight', 'Peso'),
  volume('volume', 'Volumen'),
  length('length', 'Longitud'),
  pack('pack', 'Empaque con venta por unidad'),
  fractionPack('fractionPack', 'Empaque fraccionado'),
  custom('custom', 'Personalizada');

  const UnitScaleType(this.jsonValue, this.label);

  final String jsonValue;
  final String label;

  static UnitScaleType fromJson(String? value) => values.firstWhere(
    (e) => e.jsonValue == value,
    orElse: () => UnitScaleType.custom,
  );
}

class BaseUnitScale {
  final String name;
  final UnitScaleType scaleType;
  final String baseUnit;
  final List<ExtraUnit> units;
  final int defaultUnitIndex;
  final int wholesaleUnitIndex;

  const BaseUnitScale({
    required this.name,
    this.scaleType = UnitScaleType.custom,
    required this.baseUnit,
    this.units = const [],
    this.defaultUnitIndex = 0,
    this.wholesaleUnitIndex = 0,
  });

  factory BaseUnitScale.fromJson(Map<String, dynamic> json) {
    return BaseUnitScale(
      name: json['name'] as String? ?? '',
      scaleType: UnitScaleType.fromJson(json['scaleType'] as String?),
      baseUnit: json['baseUnit'] as String? ?? '',
      units:
          (json['units'] as List<dynamic>?)
              ?.map(
                (e) => ExtraUnit.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      defaultUnitIndex: (json['defaultUnitIndex'] as num?)?.toInt() ?? 0,
      wholesaleUnitIndex: (json['wholesaleUnitIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scaleType': scaleType.jsonValue,
      'baseUnit': baseUnit,
      'units': units.map((e) => e.toJson()).toList(),
      'defaultUnitIndex': defaultUnitIndex,
      'wholesaleUnitIndex': wholesaleUnitIndex,
    };
  }
}

class CreateUnitScale extends BaseUnitScale {
  const CreateUnitScale({
    required super.name,
    super.scaleType = UnitScaleType.custom,
    required super.baseUnit,
    super.units = const [],
    super.defaultUnitIndex = 0,
    super.wholesaleUnitIndex = 0,
  });

  factory CreateUnitScale.fromJson(Map<String, dynamic> json) {
    return CreateUnitScale(
      name: json['name'] as String? ?? '',
      scaleType: UnitScaleType.fromJson(json['scaleType'] as String?),
      baseUnit: json['baseUnit'] as String? ?? '',
      units:
          (json['units'] as List<dynamic>?)
              ?.map(
                (e) => ExtraUnit.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      defaultUnitIndex: (json['defaultUnitIndex'] as num?)?.toInt() ?? 0,
      wholesaleUnitIndex: (json['wholesaleUnitIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class UpdateUnitScale {
  final String? name;
  final UnitScaleType? scaleType;
  final String? baseUnit;
  final List<ExtraUnit>? units;
  final int? defaultUnitIndex;
  final int? wholesaleUnitIndex;

  const UpdateUnitScale({
    this.name,
    this.scaleType,
    this.baseUnit,
    this.units,
    this.defaultUnitIndex,
    this.wholesaleUnitIndex,
  });

  factory UpdateUnitScale.fromJson(Map<String, dynamic> json) {
    return UpdateUnitScale(
      name: json['name'] as String?,
      scaleType: json['scaleType'] != null
          ? UnitScaleType.fromJson(json['scaleType'] as String?)
          : null,
      baseUnit: json['baseUnit'] as String?,
      units: (json['units'] as List<dynamic>?)
          ?.map((e) => ExtraUnit.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      defaultUnitIndex: (json['defaultUnitIndex'] as num?)?.toInt(),
      wholesaleUnitIndex: (json['wholesaleUnitIndex'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (scaleType != null) data['scaleType'] = scaleType!.jsonValue;
    if (baseUnit != null) data['baseUnit'] = baseUnit;
    if (units != null) data['units'] = units!.map((e) => e.toJson()).toList();
    if (defaultUnitIndex != null) data['defaultUnitIndex'] = defaultUnitIndex;
    if (wholesaleUnitIndex != null) {
      data['wholesaleUnitIndex'] = wholesaleUnitIndex;
    }
    return data;
  }
}

class UnitScaleInDb extends BaseUnitScale {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UnitScaleInDb({
    required this.id,
    required super.name,
    super.scaleType = UnitScaleType.custom,
    required super.baseUnit,
    super.units = const [],
    super.defaultUnitIndex = 0,
    super.wholesaleUnitIndex = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory UnitScaleInDb.fromJson(Map<String, dynamic> json) {
    return UnitScaleInDb(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      scaleType: UnitScaleType.fromJson(json['scaleType'] as String?),
      baseUnit: json['baseUnit'] as String? ?? '',
      units:
          (json['units'] as List<dynamic>?)
              ?.map(
                (e) => ExtraUnit.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      defaultUnitIndex: (json['defaultUnitIndex'] as num?)?.toInt() ?? 0,
      wholesaleUnitIndex: (json['wholesaleUnitIndex'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['createdAt'] as num).toInt(),
            )
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['updatedAt'] as num).toInt(),
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
