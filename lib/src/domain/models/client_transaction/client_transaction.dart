enum TransactionType { credit, debit }

enum TransactionSubType { invoice, discount, devolution, receipt }

class BaseClientTransaction {
  final String documentId;
  final String docNumber;
  final String clientId;
  final int amount;
  final TransactionType type;
  final TransactionSubType subtype;
  final int resultBalance;

  BaseClientTransaction({
    required this.documentId,
    required this.docNumber,
    required this.clientId,
    required this.amount,
    required this.type,
    required this.subtype,
    required this.resultBalance,
  });

  factory BaseClientTransaction.fromJson(Map<String, dynamic> json) {
    return BaseClientTransaction(
      documentId: json['documentId'],
      docNumber: json['docNumber'],
      clientId: json['clientId'],
      amount: json['amount'],
      type: TransactionType.values.byName(json['type']),
      subtype: TransactionSubType.values.byName(json['subtype']),
      resultBalance: json['resultBalance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'docNumber': docNumber,
      'clientId': clientId,
      'amount': amount,
      'type': type.name,
      'subtype': subtype.name,
      'resultBalance': resultBalance,
    };
  }
}

class ClientTransactionInDb extends BaseClientTransaction {
  final String id;
  final DateTime createdAt;

  ClientTransactionInDb({
    required this.id,
    required this.createdAt,
    required super.documentId,
    required super.docNumber,
    required super.clientId,
    required super.amount,
    required super.type,
    required super.subtype,
    required super.resultBalance,
  });

  factory ClientTransactionInDb.fromJson(Map<String, dynamic> json) {
    return ClientTransactionInDb(
      id: json['id'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      documentId: json['documentId'],
      docNumber: json['docNumber'],
      clientId: json['clientId'],
      amount: json['amount'],
      type: TransactionType.values.byName(json['type']),
      subtype: TransactionSubType.values.byName(json['subtype']),
      resultBalance: json['resultBalance'],
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
