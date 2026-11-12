import 'package:kardex_business/src/domain/models/common/user_info.dart';

enum AdjustmentRequestStatus { pending, approved, cancelled }

class AdjustmentRequestItem {
  final String productId;
  final String productName;
  final String image;
  final String? code;
  final String? brandName;
  final String? unitName;
  final String? standardUnitName;
  final int? standardUnitFactor;
  final int conversionFactor;
  final int systemStock;
  final int countedQuantity;
  final int difference;
  final int cost;
  final int subtotal;

  AdjustmentRequestItem({
    required this.productId,
    required this.productName,
    this.image = "",
    this.code,
    this.brandName,
    this.unitName,
    this.standardUnitName,
    this.standardUnitFactor,
    this.conversionFactor = 1,
    this.systemStock = 0,
    this.countedQuantity = 0,
    this.difference = 0,
    this.cost = 0,
    this.subtotal = 0,
  });

  factory AdjustmentRequestItem.fromJson(Map<String, dynamic> json) {
    return AdjustmentRequestItem(
      productId: json['productId'] as String? ?? "",
      productName: json['productName'] as String? ?? "",
      image: json['image'] as String? ?? "",
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      standardUnitName: json['standardUnitName'] as String?,
      standardUnitFactor: json['standardUnitFactor'] as int?,
      conversionFactor: json['conversionFactor'] as int? ?? 1,
      systemStock: json['systemStock'] as int? ?? 0,
      countedQuantity: json['countedQuantity'] as int? ?? 0,
      difference: json['difference'] as int? ?? 0,
      cost: json['cost'] as int? ?? 0,
      subtotal: json['subtotal'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'image': image,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
      'standardUnitName': standardUnitName,
      'standardUnitFactor': standardUnitFactor,
      'conversionFactor': conversionFactor,
      'systemStock': systemStock,
      'countedQuantity': countedQuantity,
      'difference': difference,
      'cost': cost,
      'subtotal': subtotal,
    };
  }
}

class BaseAdjustmentRequest {
  final String docNumber;
  final String branchId;
  final String description;
  final List<AdjustmentRequestItem> items;
  final UserInfo createdBy;

  BaseAdjustmentRequest({
    this.docNumber = "",
    required this.branchId,
    this.description = "",
    required this.items,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'docNumber': docNumber,
      'branchId': branchId,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'createdBy': createdBy.toJson(),
    };
  }
}

class CreateAdjustmentRequest extends BaseAdjustmentRequest {
  CreateAdjustmentRequest({
    super.docNumber,
    required super.branchId,
    super.description,
    required super.items,
    required super.createdBy,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'docNumber': docNumber,
      'branchId': branchId,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'createdBy': createdBy.toJson(),
    };
  }
}

class UpdateAdjustmentRequest {
  final String? description;
  final List<AdjustmentRequestItem>? items;

  UpdateAdjustmentRequest({this.description, this.items});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (description != null) data['description'] = description;
    if (items != null) data['items'] = items!.map((e) => e.toJson()).toList();
    return data;
  }
}

class AdjustmentRequestInDb extends BaseAdjustmentRequest {
  final String id;
  final AdjustmentRequestStatus status;
  final int createdAt;
  final int? updatedAt;
  final bool isDeleted;
  final UserInfo? approvedBy;
  final int? approvedAt;
  final UserInfo? cancelledBy;
  final int? cancelledAt;
  final String? cancellationReason;
  final String? adjustEntryId;
  final String? adjustEntryDocNumber;
  final String? adjustExitId;
  final String? adjustExitDocNumber;
  final int entryTotal;
  final int exitTotal;

  AdjustmentRequestInDb({
    required this.id,
    this.status = AdjustmentRequestStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.approvedBy,
    this.approvedAt,
    this.cancelledBy,
    this.cancelledAt,
    this.cancellationReason,
    this.adjustEntryId,
    this.adjustEntryDocNumber,
    this.adjustExitId,
    this.adjustExitDocNumber,
    this.entryTotal = 0,
    this.exitTotal = 0,
    super.docNumber,
    required super.branchId,
    super.description,
    required super.items,
    required super.createdBy,
  });

  factory AdjustmentRequestInDb.fromJson(Map<String, dynamic> json) {
    return AdjustmentRequestInDb(
      id: json['id'] as String,
      status: AdjustmentRequestStatus.values.byName(json['status'] as String? ?? AdjustmentRequestStatus.pending.name),
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      approvedBy: json['approvedBy'] != null ? UserInfo.fromJson(json['approvedBy']) : null,
      approvedAt: json['approvedAt'] as int?,
      cancelledBy: json['cancelledBy'] != null ? UserInfo.fromJson(json['cancelledBy']) : null,
      cancelledAt: json['cancelledAt'] as int?,
      cancellationReason: json['cancellationReason'] as String?,
      adjustEntryId: json['adjustEntryId'] as String?,
      adjustEntryDocNumber: json['adjustEntryDocNumber'] as String?,
      adjustExitId: json['adjustExitId'] as String?,
      adjustExitDocNumber: json['adjustExitDocNumber'] as String?,
      entryTotal: json['entryTotal'] as int? ?? 0,
      exitTotal: json['exitTotal'] as int? ?? 0,
      docNumber: json['docNumber'] as String? ?? "",
      branchId: json['branchId'] as String? ?? "",
      description: json['description'] as String? ?? "",
      items: (json['items'] as List? ?? const [])
          .map((e) => AdjustmentRequestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'approvedBy': approvedBy?.toJson(),
      'approvedAt': approvedAt,
      'cancelledBy': cancelledBy?.toJson(),
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
      'adjustEntryId': adjustEntryId,
      'adjustEntryDocNumber': adjustEntryDocNumber,
      'adjustExitId': adjustExitId,
      'adjustExitDocNumber': adjustExitDocNumber,
      'entryTotal': entryTotal,
      'exitTotal': exitTotal,
    });
    return data;
  }
}
