import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

class ExitItem {
  final String productId;
  final String productName;
  final String? code;
  final String? brandName;
  final String? unitName;
  final int? cost;
  final int quantity;

  ExitItem({
    required this.productId,
    required this.productName,
    this.code,
    this.brandName,
    this.unitName,
    this.cost,
    required this.quantity,
  });

  factory ExitItem.fromJson(Map<String, dynamic> json) {
    return ExitItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      code: json['code'] as String?,
      brandName: json['brandName'] as String?,
      unitName: json['unitName'] as String?,
      cost: json['cost'] as int?,
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
      'cost': cost,
      'quantity': quantity,
    };
  }
}

class Client {
  final String name;

  Client({required this.name});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class ExitHistoryInDb {
  final String clientId;
  final Client client;
  final String docNumber;
  final DateTime docDate;
  final String branchId;
  final String description;
  final List<ExitItem> items;
  final String id;
  final DateTime createdAt;
  final UserInfo createdBy;

  ExitHistoryInDb({
    required this.clientId,
    required this.client,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    required this.description,
    required this.items,
    required this.id,
    required this.createdAt,
    required this.createdBy,
  });

  int get total {
    return items.fold(0, (sum, item) => sum + ((item.cost ?? 0) * item.quantity.abs()));
  }

  factory ExitHistoryInDb.fromJson(Map<String, dynamic> json) {
    return ExitHistoryInDb(
      clientId: json['clientId'] as String,
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String,
      items: (json['items'] as List<dynamic>).map((item) => ExitItem.fromJson(item as Map<String, dynamic>)).toList(),
      id: json['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      createdBy: UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'client': client.toJson(),
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
