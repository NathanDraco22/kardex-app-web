enum TransactionType {
  entry,
  exit,
}

enum TransactionSubType { entry, exit, invoice, devolution, transfer, adjustment, loss, creditNote }

class BaseProductTransaction {
  final String documentId;
  final String docNumber;
  final TransactionType type;
  final TransactionSubType subtype;
  final String productId;
  final String branchId;
  final int quantity;
  final int averageCost;
  final int resultStock;

  BaseProductTransaction({
    required this.documentId,
    required this.docNumber,
    required this.type,
    required this.subtype,
    required this.productId,
    required this.branchId,
    required this.quantity,
    required this.averageCost,
    required this.resultStock,
  });

  factory BaseProductTransaction.fromJson(Map<String, dynamic> json) => BaseProductTransaction(
    documentId: json['documentId'],
    docNumber: json['docNumber'],
    type: TransactionType.values.byName(json['type']),
    subtype: switch (json['subtype']) {
      'credit_note' => TransactionSubType.creditNote,
      _ => TransactionSubType.values.byName(json['subtype']),
    },
    productId: json['productId'],
    branchId: json['branchId'],
    quantity: json['quantity'],
    averageCost: json['averageCost'],
    resultStock: json['resultStock'],
  );

  Map<String, dynamic> toJson() => {
    'documentId': documentId,
    'docNumber': docNumber,
    'type': type.name,
    'subtype': subtype == TransactionSubType.creditNote ? 'credit_note' : subtype.name,
    'productId': productId,
    'branchId': branchId,
    'quantity': quantity,
    'averageCost': averageCost,
    'resultStock': resultStock,
  };
}

class ProductTransactionInDb extends BaseProductTransaction {
  final String id;
  final DateTime createdAt;

  ProductTransactionInDb({
    required this.id,
    required this.createdAt,
    required super.documentId,
    required super.docNumber,
    required super.type,
    required super.subtype,
    required super.productId,
    required super.branchId,
    required super.quantity,
    required super.averageCost,
    required super.resultStock,
  });

  factory ProductTransactionInDb.fromJson(Map<String, dynamic> json) => ProductTransactionInDb(
    id: json['id'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    documentId: json['documentId'],
    docNumber: json['docNumber'],
    type: TransactionType.values.byName(json['type']),
    subtype: switch (json['subtype']) {
      'credit_note' => TransactionSubType.creditNote,
      _ => TransactionSubType.values.byName(json['subtype']),
    },
    productId: json['productId'],
    branchId: json['branchId'],
    quantity: json['quantity'],
    averageCost: json['averageCost'],
    resultStock: json['resultStock'],
  );

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['id'] = id;
    data['createdAt'] = createdAt.millisecondsSinceEpoch;
    return data;
  }
}
