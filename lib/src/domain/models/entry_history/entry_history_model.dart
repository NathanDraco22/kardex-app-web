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
  final String id;
  final DateTime createdAt;

  EntryHistoryInDb({
    required this.supplierId,
    required this.supplier,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    required this.description,
    required this.id,
    required this.createdAt,
  });

  factory EntryHistoryInDb.fromJson(Map<String, dynamic> json) {
    return EntryHistoryInDb(
      supplierId: json['supplierId'] as String,
      supplier: Supplier.fromJson(json['supplier'] as Map<String, dynamic>),
      docNumber: json['docNumber'] as String,
      docDate: DateTime.parse(json['docDate'] as String),
      branchId: json['branchId'] as String,
      description: json['description'] as String,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'supplier': supplier.toJson(),
      'docNumber': docNumber,
      'docDate': docDate.toIso8601String(),
      'branchId': branchId,
      'description': description,
      'id': id,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
