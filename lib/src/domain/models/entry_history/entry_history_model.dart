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

class Supplier {
  final String name;

  Supplier({required this.name});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class EntryHistoryInDb {
  final String supplierId;
  final Supplier supplier;
  final String docNumber;
  final DateTime docDate;
  final String branchId;
  final String description;
  final List<EntryItem> items;
  final String id;
  final UserInfo createdBy;
  final DateTime createdAt;

  int get total {
    return items.fold(0, (total, item) => total + item.cost * item.quantity);
  }

  EntryHistoryInDb({
    required this.supplierId,
    required this.supplier,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    required this.description,
    required this.items,
    required this.id,
    required this.createdAt,
    required this.createdBy,
  });

  factory EntryHistoryInDb.fromJson(Map<String, dynamic> json) {
    return EntryHistoryInDb(
      supplierId: json['supplierId'] as String,
      supplier: Supplier.fromJson(json['supplier'] as Map<String, dynamic>),
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String,
      items: (json['items'] as List<dynamic>).map((item) => EntryItem.fromJson(item as Map<String, dynamic>)).toList(),
      id: json['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      createdBy: UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'supplier': supplier.toJson(),
      'docNumber': docNumber,
      'docDate': docDate.millisecondsSinceEpoch,
      'branchId': branchId,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'createdBy': createdBy.toJson(),
    };
  }
}
