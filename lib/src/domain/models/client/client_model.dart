class BaseClient {
  final String name;

  BaseClient({required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CreateClient extends BaseClient {
  CreateClient({required super.name});

  factory CreateClient.fromJson(Map json) {
    return CreateClient(
      name: json['name'] as String,
    );
  }
}

class UpdateClient {
  final String? name;

  UpdateClient({this.name});

  factory UpdateClient.fromJson(Map json) {
    return UpdateClient(
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) {
      data['name'] = name;
    }
    return data;
  }
}

class ClientInDb extends BaseClient {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClientInDb({
    required this.id,
    required super.name,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClientInDb.fromJson(Map<String, dynamic> json) {
    return ClientInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });
    return data;
  }
}
