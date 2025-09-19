class ExitItem {
  final String productId;
  final int quantity;

  ExitItem({
    required this.productId,
    required this.quantity,
  }) : assert(quantity < 0, 'La cantidad en una salida debe ser negativa.');

  factory ExitItem.fromJson(Map<String, dynamic> json) {
    return ExitItem(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
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

  BaseExitDoc({
    required this.clientId,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    this.description = "",
    required this.items,
  });

  factory BaseExitDoc.fromJson(Map<String, dynamic> json) {
    return BaseExitDoc(
      clientId: json['clientId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => ExitItem.fromJson(item as Map<String, dynamic>)).toList(),
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
  });

  factory CreateExitDoc.fromJson(Map<String, dynamic> json) {
    return CreateExitDoc(
      clientId: json['clientId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.fromMillisecondsSinceEpoch(json['docDate'] as int),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => ExitItem.fromJson(item as Map<String, dynamic>)).toList(),
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
