import 'dart:convert';

import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/services/hive_service.dart';
import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';

class TransferDraft {
  final BranchInDb? destinationBranch;
  final String? observations;
  final List<TransferProductRow> rows;

  TransferDraft({
    this.destinationBranch,
    this.observations,
    this.rows = const [],
  });

  factory TransferDraft.fromJson(Map<String, dynamic> json) {
    final branchJson = json['destinationBranch'];
    final rowsJson = json['rows'] as List?;
    return TransferDraft(
      destinationBranch: branchJson != null ? BranchInDb.fromJson(branchJson) : null,
      observations: json['observations'] as String?,
      rows: rowsJson != null
          ? rowsJson.map((rowJson) {
              final productJson = rowJson['product'];
              final dateStr = rowJson['expirationDate'] as String?;
              return TransferProductRow(
                product: ProductInDbInBranch.fromJson(productJson),
                quantity: rowJson['quantity'] as int? ?? 0,
                unitaryCost: rowJson['unitaryCost'] as int? ?? 0,
                expirationDate: dateStr != null ? DateTime.tryParse(dateStr) : null,
              );
            }).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destinationBranch': destinationBranch?.toJson(),
      'observations': observations,
      'rows': rows
          .map((row) => {
                'product': row.product.toJson(),
                'quantity': row.quantity,
                'unitaryCost': row.unitaryCost,
                'expirationDate': row.expirationDate?.toIso8601String(),
              })
          .toList(),
    };
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
