class BaseClientGroup {
  final String name;
  final String description;

  BaseClientGroup({
    required this.name,
    this.description = "",
  });

  factory BaseClientGroup.fromJson(Map<String, dynamic> json) {
    return BaseClientGroup(
      name: json['name'] as String,
      description: json['description'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class CreateClientGroup extends BaseClientGroup {
  CreateClientGroup({
    required super.name,
    super.description,
  });

  factory CreateClientGroup.fromJson(Map<String, dynamic> json) {
    return CreateClientGroup(
      name: json['name'] as String,
      description: json['description'] as String? ?? "",
    );
  }
}

class UpdateClientGroup {
  final String? name;
  final String? description;

  UpdateClientGroup({
    this.name,
    this.description,
  });

  factory UpdateClientGroup.fromJson(Map<String, dynamic> json) {
    return UpdateClientGroup(
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ClientGroupInDb extends BaseClientGroup {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClientGroupInDb({
    required this.id,
    required super.name,
    super.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClientGroupInDb.fromJson(Map<String, dynamic> json) {
    return ClientGroupInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? "",
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}
