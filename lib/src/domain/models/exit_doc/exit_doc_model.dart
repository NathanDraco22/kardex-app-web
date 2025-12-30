import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

class ExitItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int quantity;

  ExitItem({
    required this.productId,
    required this.productName,
    this.code,
    this.brandName,
    this.unitName,
    required this.quantity,
  }) : assert(quantity < 0, 'La cantidad en una salida debe ser negativa.');

  factory ExitItem.fromJson(Map<String, dynamic> json) {
    return ExitItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'code': code,
      'brandName': brandName,
      'unitName': unitName,
      'quantity': quantity,
    };
  }
}

class BaseExitDoc {
  final String clientId;
  final String docNumber;
  final DateTime docDate;
  final String branchId;
  final String description;
  final List<ExitItem> items;
  final UserInfo createdBy;

  BaseExitDoc({
    required this.clientId,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    this.description = "",
    required this.items,
    required this.createdBy,
  });

  factory BaseExitDoc.fromJson(Map<String, dynamic> json) {
    return BaseExitDoc(
      clientId: json['clientId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => ExitItem.fromJson(item as Map<String, dynamic>)).toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'docNumber': docNumber,
      'docDate': docDate.millisecondsSinceEpoch,
      'branchId': branchId,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'createdBy': createdBy.toJson(),
    };
  }
}

class CreateExitDoc extends BaseExitDoc {
  CreateExitDoc({
    required super.clientId,
    required super.docNumber,
    required super.docDate,
    required super.branchId,
    super.description,
    required super.items,
    required super.createdBy,
  });

  factory CreateExitDoc.fromJson(Map<String, dynamic> json) {
    return CreateExitDoc(
      clientId: json['clientId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => ExitItem.fromJson(item as Map<String, dynamic>)).toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }
}

class ExitDocInDb extends BaseExitDoc {
  final String id;
  final DateTime createdAt;

  ExitDocInDb({
    required this.id,
    required super.clientId,
    required super.docNumber,
    required super.docDate,
    required super.branchId,
    super.description,
    required super.items,
    required this.createdAt,
    required super.createdBy,
  });

  factory ExitDocInDb.fromJson(Map<String, dynamic> json) {
    return ExitDocInDb(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => ExitItem.fromJson(item as Map<String, dynamic>)).toList(),
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
