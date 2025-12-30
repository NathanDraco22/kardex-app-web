import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

class EntryItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int cost;
  final int quantity;
  final int? expirationDate;

  EntryItem({
    required this.productId,
    required this.productName,
    required this.cost,
    required this.quantity,
    this.expirationDate,
    this.code,
    this.brandName,
    this.unitName,
  });

  factory EntryItem.fromJson(Map<String, dynamic> json) {
    return EntryItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      cost: json['cost'] as int,
      quantity: json['quantity'] as int,
      expirationDate: json['expirationDate'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'cost': cost,
      'quantity': quantity,
      'expirationDate': expirationDate,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
    };
  }
}

class BaseEntryDoc {
  final String supplierId;
  final String docNumber;
  final DateTime docDate;
  final String branchId;
  final String description;
  final List<EntryItem> items;
  final UserInfo createdBy;

  BaseEntryDoc({
    required this.supplierId,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    this.description = "",
    required this.items,
    required this.createdBy,
  });

  factory BaseEntryDoc.fromJson(Map<String, dynamic> json) {
    return BaseEntryDoc(
      supplierId: json['supplierId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => EntryItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'docNumber': docNumber,
      'docDate': docDate.millisecondsSinceEpoch,
      'branchId': branchId,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'createdBy': createdBy.toJson(),
    };
  }
}

class CreateEntryDoc extends BaseEntryDoc {
  CreateEntryDoc({
    required super.supplierId,
    required super.docNumber,
    required super.docDate,
    required super.branchId,
    super.description,
    required super.items,
    required super.createdBy,
  });

  factory CreateEntryDoc.fromJson(Map<String, dynamic> json) {
    return CreateEntryDoc(
      supplierId: json['supplierId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => EntryItem.fromJson(item as Map<String, dynamic>)).toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }
}

class EntryDocInDb extends BaseEntryDoc {
  final String id;
  final DateTime createdAt;

  EntryDocInDb({
    required this.id,
    required super.supplierId,
    required super.docNumber,
    required super.docDate,
    required super.branchId,
    super.description,
    required super.items,
    required this.createdAt,
    required super.createdBy,
  });

  factory EntryDocInDb.fromJson(Map<String, dynamic> json) {
    return EntryDocInDb(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => EntryItem.fromJson(item as Map<String, dynamic>)).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
    });
    return data;
  }
}
