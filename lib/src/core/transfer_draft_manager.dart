import 'dart:convert';
import 'dart:math';

import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';

/// Borrador de transferencia entre sucursales.
///
/// Historial de versiones:
/// - **v1:** no guardaba la unidad. `quantity` y `unitaryCost` están en unidad
///   base.
/// - **v2:** guarda `selectedUnitIndex`, `conversionFactor` y
///   `selectedUnitName`. `quantity` y `unitaryCost` están en la unidad
///   comercial seleccionada (display/comercial), no en unidad base.
/// - **v3:** agrega `baseUnitName`, `standardUnitName` y `standardUnitFactor`
///   por fila. La semántica de `quantity`/`unitaryCost` sigue siendo comercial.
///
/// Al restaurar se reconstruye la cantidad base con el factor guardado y se
/// recalcula el costo comercial desde `averageCost`. Si la unidad ya no existe
/// o la unidad base cambió, se marca [needsUnitReview] y se permite continuar
/// con los valores reconstruidos.
class TransferDraft {
  static const int currentVersion = 3;

  final BranchInDb? destinationBranch;
  final String? observations;
  final List<TransferProductRow> rows;
  final bool needsUnitReview;

  /// Detalle de las filas que requirieron reconstrucción de unidad/costo.
  final List<TransferDraftUnitReview> reviews;

  TransferDraft({
    this.destinationBranch,
    this.observations,
    this.rows = const [],
    this.needsUnitReview = false,
    this.reviews = const [],
  });

  factory TransferDraft.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as num?)?.toInt() ?? 1;
    final branchJson = json['destinationBranch'];
    final rowsJson = json['rows'] as List?;

    final rows = <TransferProductRow>[];
    final reviews = <TransferDraftUnitReview>[];

    if (rowsJson != null) {
      for (final rawRow in rowsJson) {
        final rowJson = Map<String, dynamic>.from(rawRow as Map);
        final product = ProductInDbInBranch.fromJson(
          Map<String, dynamic>.from(rowJson['product'] as Map),
        );
        final dateStr = rowJson['expirationDate'] as String?;

        final resolution = TransferDraftUnitResolver.resolve(
          version: version,
          savedQuantity: (rowJson['quantity'] as num?)?.toInt() ?? 0,
          savedUnitaryCost: (rowJson['unitaryCost'] as num?)?.toInt() ?? 0,
          savedUnitIndex: (rowJson['selectedUnitIndex'] as num?)?.toInt(),
          savedFactor: (rowJson['conversionFactor'] as num?)?.toInt(),
          savedUnitName: rowJson['selectedUnitName'] as String?,
          savedBaseUnitName: rowJson['baseUnitName'] as String?,
          productBaseUnitName: product.unitName,
          productDefaultUnitIndex: product.defaultUnitIndex,
          productExtraUnits: product.extraUnits
              .map(
                (unit) => TransferDraftUnitOption(
                  name: unit.name,
                  factor: unit.conversionFactor,
                ),
              )
              .toList(growable: false),
          averageCost: product.account.averageCost,
        );

        if (resolution.needsReview) {
          reviews.add(
            TransferDraftUnitReview(
              productName: product.name,
              quantity: resolution.quantity,
              baseQuantity: resolution.baseQuantity,
              unitName: resolution.selectedUnitName,
              baseUnitName: resolution.baseUnitName,
              unitaryCost: resolution.unitaryCost,
              reasons: resolution.reviewReasons,
            ),
          );
        }

        rows.add(
          TransferProductRow(
            product: product,
            quantity: resolution.quantity,
            unitaryCost: resolution.unitaryCost,
            expirationDate: dateStr != null ? DateTime.tryParse(dateStr) : null,
            selectedUnitIndex: resolution.selectedUnitIndex,
            conversionFactor: resolution.conversionFactor,
            selectedUnitName: resolution.selectedUnitName,
          ),
        );
      }
    }

    return TransferDraft(
      destinationBranch: branchJson != null ? BranchInDb.fromJson(Map<String, dynamic>.from(branchJson as Map)) : null,
      observations: json['observations'] as String?,
      rows: rows,
      needsUnitReview: reviews.isNotEmpty,
      reviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': currentVersion,
      'destinationBranch': destinationBranch?.toJson(),
      'observations': observations,
      'rows': rows.map((row) {
        final selectedUnitName = UnitConversionTool.resolveUnitName(
          row.selectedUnitName,
          row.product.unitName,
        );
        return {
          'product': row.product.toJson(),
          'quantity': row.quantity,
          'unitaryCost': row.unitaryCost,
          'expirationDate': row.expirationDate?.toIso8601String(),
          'selectedUnitIndex': row.selectedUnitIndex,
          'conversionFactor': row.conversionFactor,
          'selectedUnitName': selectedUnitName,
          'baseUnitName': row.product.unitName,
          'standardUnitName': row.product.defaultUnitName,
          'standardUnitFactor': row.product.defaultUnitFactor,
        };
      }).toList(),
    };
  }
}

/// Datos de unidad de una fila que necesitaron reconstrucción al restaurar.
class TransferDraftUnitReview {
  const TransferDraftUnitReview({
    required this.productName,
    required this.quantity,
    required this.baseQuantity,
    required this.unitName,
    required this.baseUnitName,
    required this.unitaryCost,
    required this.reasons,
  });

  final String productName;
  final int quantity;
  final int baseQuantity;
  final String unitName;
  final String baseUnitName;
  final int unitaryCost;
  final List<String> reasons;

  String get reason => reasons.join(' ');
}

/// Unidad comercial disponible en el producto.
class TransferDraftUnitOption {
  const TransferDraftUnitOption({
    required this.name,
    required this.factor,
  });

  final String name;
  final int factor;
}

/// Resultado de reconstruir una fila del borrador.
class TransferDraftUnitResolution {
  const TransferDraftUnitResolution({
    required this.selectedUnitIndex,
    required this.conversionFactor,
    required this.selectedUnitName,
    required this.quantity,
    required this.baseQuantity,
    required this.unitaryCost,
    required this.baseUnitName,
    required this.standardUnitName,
    required this.standardUnitFactor,
    required this.needsReview,
    required this.reviewReasons,
  });

  /// Cantidad en la unidad comercial restaurada (display).
  final int quantity;

  /// Cantidad en unidad base.
  final int baseQuantity;

  /// Costo comercial en la unidad restaurada.
  final int unitaryCost;

  final int selectedUnitIndex;
  final int conversionFactor;
  final String selectedUnitName;
  final String baseUnitName;
  final String standardUnitName;
  final int standardUnitFactor;
  final bool needsReview;
  final List<String> reviewReasons;
}

/// Reconstrucción pura de unidad, cantidad y costo de un borrador.
class TransferDraftUnitResolver {
  const TransferDraftUnitResolver._();

  static TransferDraftUnitResolution resolve({
    required int version,
    required int savedQuantity,
    required int savedUnitaryCost,
    required int? savedUnitIndex,
    required int? savedFactor,
    required String? savedUnitName,
    required String? savedBaseUnitName,
    required String productBaseUnitName,
    required int productDefaultUnitIndex,
    required List<TransferDraftUnitOption> productExtraUnits,
    required int averageCost,
  }) {
    final extras = productExtraUnits
        .map(
          (unit) => TransferDraftUnitOption(
            name: unit.name,
            factor: UnitConversionTool.ensureSafeFactor(unit.factor),
          ),
        )
        .toList(growable: false);
    final baseOption = TransferDraftUnitOption(
      name: productBaseUnitName,
      factor: 1,
    );
    final defaultOption = _optionForIndex(
      productDefaultUnitIndex,
      extras,
      baseOption,
    );
    final standardUnitName = defaultOption.name;
    final standardUnitFactor = defaultOption.factor;

    final safeSavedFactor = savedFactor != null && savedFactor > 0 ? savedFactor : null;
    final hasUnitData = savedUnitIndex != null && safeSavedFactor != null;
    final savedName = (savedUnitName ?? '').trim();
    final savedBaseName = (savedBaseUnitName ?? '').trim();
    final normalizedProductBaseName = productBaseUnitName.trim();

    final reasons = <String>[];
    var baseChanged = savedBaseName.isNotEmpty && savedBaseName != normalizedProductBaseName;

    if (!baseChanged &&
        hasUnitData &&
        savedUnitIndex == 0 &&
        savedName.isNotEmpty &&
        savedName != normalizedProductBaseName) {
      // Borradores v2 no guardaban baseUnitName: el nombre de la unidad base
      // seleccionada permite detectar el cambio en el índice 0.
      baseChanged = true;
    }

    var selection = baseOption;
    var baseQuantity = max(savedQuantity, 0);

    if (!hasUnitData) {
      reasons.add(
        version < 2 ? 'El borrador no guardó la unidad de medida.' : 'El borrador no tiene datos de unidad válidos.',
      );
      selection = defaultOption;
    } else {
      // En v2/v3 la cantidad guardada es display de la unidad comercial.
      baseQuantity = max(savedQuantity, 0) * safeSavedFactor;

      if (baseChanged) {
        reasons.add(
          'La unidad base del producto cambió de "$savedBaseName" '
          'a "$normalizedProductBaseName".',
        );
        selection = defaultOption;
      } else if (savedUnitIndex == 0) {
        if (safeSavedFactor != 1) {
          reasons.add('El factor guardado para la unidad base no es válido.');
        }
        selection = baseOption;
      } else if (savedUnitIndex > 0 && savedUnitIndex <= extras.length) {
        final indexed = extras[savedUnitIndex - 1];
        final nameMatches = savedName.isEmpty || savedName == indexed.name.trim();
        if (indexed.factor == safeSavedFactor && nameMatches) {
          selection = indexed;
        } else {
          final relocated = _findUnit(
            extras,
            name: savedName,
            factor: safeSavedFactor,
          );
          if (relocated != null) {
            selection = relocated;
            reasons.add(
              'La unidad "${relocated.name}" cambió de posición en el producto.',
            );
          } else {
            reasons.add(
              'La unidad "${savedName.isEmpty ? savedUnitIndex : savedName}" '
              'ya no existe en el producto; se restauró en unidad base.',
            );
            selection = baseOption;
          }
        }
      } else {
        final relocated = _findUnit(
          extras,
          name: savedName,
          factor: safeSavedFactor,
        );
        if (relocated != null) {
          selection = relocated;
          reasons.add(
            'La unidad "${relocated.name}" cambió de posición en el producto.',
          );
        } else {
          reasons.add(
            'La unidad "${savedName.isEmpty ? savedUnitIndex : savedName}" '
            'ya no existe en el producto; se restauró en unidad base.',
          );
          selection = baseOption;
        }
      }
    }

    var resolvedQuantity = baseQuantity;
    if (selection.factor > 1) {
      if (baseQuantity % selection.factor == 0) {
        resolvedQuantity = baseQuantity ~/ selection.factor;
      } else {
        reasons.add(
          'La cantidad no es divisible por la unidad "${selection.name}"; '
          'se muestra en "${baseOption.name}".',
        );
        selection = baseOption;
        resolvedQuantity = baseQuantity;
      }
    }

    final hasAverageCost = averageCost > 0;
    final int resolvedUnitaryCost;
    if (hasAverageCost) {
      resolvedUnitaryCost = averageCost * selection.factor;
    } else {
      reasons.add(
        'No hay costo promedio disponible; se conservó el costo del borrador.',
      );
      if (!hasUnitData) {
        // v1 guardaba el costo en unidad base.
        resolvedUnitaryCost = savedUnitaryCost * selection.factor;
      } else {
        // v2/v3 guardaban el costo comercial en la unidad seleccionada.
        resolvedUnitaryCost = (savedUnitaryCost * selection.factor / safeSavedFactor).round();
      }
    }

    return TransferDraftUnitResolution(
      selectedUnitIndex: _indexOf(selection, extras, baseOption),
      conversionFactor: selection.factor,
      selectedUnitName: selection.name,
      quantity: resolvedQuantity,
      baseQuantity: baseQuantity,
      unitaryCost: resolvedUnitaryCost,
      baseUnitName: baseOption.name,
      standardUnitName: standardUnitName,
      standardUnitFactor: standardUnitFactor,
      needsReview: reasons.isNotEmpty,
      reviewReasons: List.unmodifiable(reasons),
    );
  }

  static TransferDraftUnitOption _optionForIndex(
    int index,
    List<TransferDraftUnitOption> extras,
    TransferDraftUnitOption baseOption,
  ) {
    if (index > 0 && index <= extras.length) return extras[index - 1];
    return baseOption;
  }

  static TransferDraftUnitOption? _findUnit(
    List<TransferDraftUnitOption> extras, {
    required String name,
    required int factor,
  }) {
    for (final unit in extras) {
      if (unit.factor != factor) continue;
      if (name.isEmpty || unit.name.trim() == name) return unit;
    }
    return null;
  }

  static int _indexOf(
    TransferDraftUnitOption selection,
    List<TransferDraftUnitOption> extras,
    TransferDraftUnitOption baseOption,
  ) {
    if (identical(selection, baseOption)) return 0;
    final index = extras.indexOf(selection);
    return index < 0 ? 0 : index + 1;
  }
}

class TransferDraftManager with HiveService {
  final _boxName = 'transferDraftBox';

  static final TransferDraftManager _instance = TransferDraftManager._internal();
  factory TransferDraftManager() => _instance;
  TransferDraftManager._internal();

  Future<void> saveDraft(String branchId, TransferDraft draft) async {
    final data = json.encode(draft.toJson());
    final box = await getBox(_boxName);
    await box.put(branchId, data);
  }

  Future<TransferDraft?> getDraft(String branchId) async {
    final box = await getBox(_boxName);
    final data = box.get(branchId);
    if (data == null) return null;

    final Map<String, dynamic> draftJson = json.decode(data);
    return TransferDraft.fromJson(draftJson);
  }

  Future<void> clearDraft(String branchId) async {
    final box = await getBox(_boxName);
    await box.delete(branchId);
  }

  Future<bool> hasDraft(String branchId) async {
    final box = await getBox(_boxName);
    return box.containsKey(branchId);
  }
}
