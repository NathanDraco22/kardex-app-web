class UserRole {
  final String name;
  final List<String> access;

  UserRole({
    required this.name,
    required this.access,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
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

class BaseUser {
  final String username;
  final String password;
  final bool isActive;
  final String role;

  BaseUser({
    required this.username,
    required this.password,
    this.isActive = true,
    required this.role,
  });

  factory BaseUser.fromJson(Map<String, dynamic> json) {
    return BaseUser(
      username: json['username'] as String,
      password: json['password'] as String,
      isActive: json['isActive'] as bool? ?? true,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'isActive': isActive,
      'role': role,
    };
  }
}

class CreateUser extends BaseUser {
  CreateUser({
    required super.username,
    required super.password,
    super.isActive,
    required super.role,
  });

  factory CreateUser.fromJson(Map<String, dynamic> json) {
    return CreateUser(
      username: json['username'] as String,
      password: json['password'] as String,
      isActive: json['isActive'] as bool? ?? true,
      role: json['role'] as String,
    );
  }
}

class UpdateUser {
  final String? username;
  final bool? isActive;
  final String? role;

  UpdateUser({
    this.username,
    this.isActive,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'isActive': isActive,
      'role': role,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class UserInDb extends BaseUser {
  final String id;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserInDb({
    required this.id,
    required super.username,
    required super.password,
    super.isActive,
    required super.role,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserInDb.fromJson(Map<String, dynamic> json) {
    return UserInDb(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      isActive: json['isActive'] as bool? ?? true,
      role: json['role'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'isDeleted': isDeleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    });
    return data;
  }
}

class UserInDbWithRole extends UserInDb {
  final UserRole userRole;

  UserInDbWithRole({
    required super.id,
    required super.username,
    required super.password,
    required super.role,
    super.isActive,
    super.isDeleted,
    required super.createdAt,
    super.updatedAt,
    required this.userRole,
  });

  factory UserInDbWithRole.fromJson(Map json) {
    return UserInDbWithRole(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      isActive: json['isActive'] as bool? ?? true,
      role: json['role'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
      userRole: UserRole.fromJson(json['userRole'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['userRole'] = userRole.toJson();
    return data;
  }
}
