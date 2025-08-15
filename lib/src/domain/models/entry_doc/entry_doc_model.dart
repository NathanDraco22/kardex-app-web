// Modelo para los items anidados dentro del documento
class EntryItem {
  final String productId;
  final int cost;
  final int quantity;

  EntryItem({
    required this.productId,
    required this.cost,
    required this.quantity,
  });

  factory EntryItem.fromJson(Map<String, dynamic> json) {
    return EntryItem(
      productId: json['productId'] as String,
      cost: json['cost'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'cost': cost,
      'quantity': quantity,
    };
  }
}

// Clase base para el documento de entrada
class BaseEntryDoc {
  final String supplierId;
  final String docNumber;
  final DateTime docDate;
  final String branchId;
  final String description;
  final List<EntryItem> items;

  BaseEntryDoc({
    required this.supplierId,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    this.description = "",
    required this.items,
  });

  factory BaseEntryDoc.fromJson(Map<String, dynamic> json) {
    return BaseEntryDoc(
      supplierId: json['supplierId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.parse(json['docDate'] as String),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>)
          .map(
            (item) => EntryItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'docNumber': docNumber,
      'docDate': docDate.toIso8601String(),
      'branchId': branchId,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

// Clase para crear un nuevo documento
class CreateEntryDoc extends BaseEntryDoc {
  CreateEntryDoc({
    required super.supplierId,
    required super.docNumber,
    required super.docDate,
    required super.branchId,
    super.description,
    required super.items,
  });

  factory CreateEntryDoc.fromJson(Map<String, dynamic> json) {
    return CreateEntryDoc(
      supplierId: json['supplierId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.parse(json['docDate'] as String),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => EntryItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

// Clase que representa el documento en la base de datos
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
  });

  factory EntryDocInDb.fromJson(Map<String, dynamic> json) {
    return EntryDocInDb(
      id: json['id'] as String,
      supplierId: json['supplierId'] as String,
      docNumber: json['docNumber'] as String,
      docDate: DateTime.parse(json['docDate'] as String),
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List<dynamic>).map((item) => EntryItem.fromJson(item as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.toIso8601String(),
    });
    return data;
  }
}
