class BaseClient {
  final String name;
  final String? cardId;
  final String? phone;
  final bool isActive;

  BaseClient({
    required this.name,
    this.cardId,
    this.phone,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardId': cardId,
      'phone': phone,
      'isActive': isActive,
    };
  }
}

class CreateClient extends BaseClient {
  CreateClient({
    required super.name,
    required super.cardId,
    required super.phone,
    required super.isActive,
  });

  factory CreateClient.fromJson(Map json) {
    return CreateClient(
      name: json['name'] as String,
      cardId: json['cardId'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}

class UpdateClient {
  final String? name;
  final String? cardId;
  final String? phone;
  final bool? isActive;

  UpdateClient({this.name, this.cardId, this.phone, this.isActive});

  factory UpdateClient.fromJson(Map json) {
    return UpdateClient(
      name: json['name'] as String?,
      cardId: json['cardId'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'cardId': cardId,
      'phone': phone,
      'isActive': isActive,
    };

    data.removeWhere((key, value) => value == null);

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
    super.cardId,
    super.phone,
    super.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClientInDb.fromJson(Map<String, dynamic> json) {
    return ClientInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      cardId: json['cardId'] as String,
      phone: json['phone'] as String,
      isActive: json['isActive'] as bool,
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
