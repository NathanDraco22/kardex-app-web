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
  final String id;
  final DateTime createdAt;

  ExitHistoryInDb({
    required this.clientId,
    required this.client,
    required this.docNumber,
    required this.docDate,
    required this.branchId,
    required this.description,
    required this.id,
    required this.createdAt,
  });

  factory ExitHistoryInDb.fromJson(Map<String, dynamic> json) {
    return ExitHistoryInDb(
      clientId: json['clientId'] as String,
      client: Client.fromJson(json['client'] as Map<String, dynamic>),
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
      'clientId': clientId,
      'client': client.toJson(),
      'docNumber': docNumber,
      'docDate': docDate.toIso8601String(),
      'branchId': branchId,
      'description': description,
      'id': id,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// TODO: implementar las demas capas.
// TODO: clientes y proveedores opcionales para consultas
