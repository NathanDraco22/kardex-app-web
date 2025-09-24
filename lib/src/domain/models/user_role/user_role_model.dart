class BaseUserRole {
  final String name;
  final List<String> access;

  BaseUserRole({
    required this.name,
    required this.access,
  });

  factory BaseUserRole.fromJson(Map<String, dynamic> json) {
    return BaseUserRole(
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'access': access,
    };
  }
}

class CreateUserRole extends BaseUserRole {
  CreateUserRole({
    required super.name,
    required super.access,
  });

  factory CreateUserRole.fromJson(Map<String, dynamic> json) {
    return CreateUserRole(
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
    );
  }
}

class UpdateUserRole {
  final String? name;
  final List<String>? access;

  UpdateUserRole({this.name, this.access});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'access': access,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class UserRoleInDb extends BaseUserRole {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserRoleInDb({
    required this.id,
    required super.name,
    required super.access,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserRoleInDb.fromJson(Map<String, dynamic> json) {
    return UserRoleInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int) : null,
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
