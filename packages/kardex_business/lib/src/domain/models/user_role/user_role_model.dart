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
  final bool isDefault;

  UserRoleInDb({
    required this.id,
    required super.name,
    required super.access,
    required this.createdAt,
    this.updatedAt,
    this.isDefault = false,
  });

  factory UserRoleInDb.fromJson(Map<String, dynamic> json) {
    return UserRoleInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDefault': isDefault,
    });
    return data;
  }
}

class SubModuleDefinition {
  final String key;
  final String name;
  final String description;

  const SubModuleDefinition({
    required this.key,
    required this.name,
    required this.description,
  });

  factory SubModuleDefinition.fromJson(Map<String, dynamic> json) {
    return SubModuleDefinition(
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}

class ModuleDefinition {
  final String key;
  final String name;
  final String description;
  final List<SubModuleDefinition> submodules;

  const ModuleDefinition({
    required this.key,
    required this.name,
    required this.description,
    this.submodules = const [],
  });

  factory ModuleDefinition.fromJson(Map<String, dynamic> json) {
    final rawSubmodules = json['submodules'] as List? ?? [];
    return ModuleDefinition(
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      submodules: rawSubmodules
          .map((e) => SubModuleDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModulesCatalog {
  final String allAccessKey;
  final List<ModuleDefinition> modules;

  const ModulesCatalog({
    required this.allAccessKey,
    required this.modules,
  });

  factory ModulesCatalog.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'] as List? ?? [];
    return ModulesCatalog(
      allAccessKey: json['allAccessKey'] as String? ?? 'all',
      modules: rawModules
          .map((e) => ModuleDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
