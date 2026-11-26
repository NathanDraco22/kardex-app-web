class RoleCapabilities {
  final bool allowInvoicing;
  final bool allowCreditInvoicing;
  final bool showClientCreditDetails;

  const RoleCapabilities({
    this.allowInvoicing = true,
    this.allowCreditInvoicing = true,
    this.showClientCreditDetails = true,
  });

  factory RoleCapabilities.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RoleCapabilities();
    return RoleCapabilities(
      allowInvoicing: json['allowInvoicing'] as bool? ?? true,
      allowCreditInvoicing: json['allowCreditInvoicing'] as bool? ?? true,
      showClientCreditDetails: json['showClientCreditDetails'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowInvoicing': allowInvoicing,
      'allowCreditInvoicing': allowCreditInvoicing,
      'showClientCreditDetails': showClientCreditDetails,
    };
  }

  RoleCapabilities copyWith({
    bool? allowInvoicing,
    bool? allowCreditInvoicing,
    bool? showClientCreditDetails,
  }) {
    return RoleCapabilities(
      allowInvoicing: allowInvoicing ?? this.allowInvoicing,
      allowCreditInvoicing: allowCreditInvoicing ?? this.allowCreditInvoicing,
      showClientCreditDetails:
          showClientCreditDetails ?? this.showClientCreditDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoleCapabilities &&
        other.allowInvoicing == allowInvoicing &&
        other.allowCreditInvoicing == allowCreditInvoicing &&
        other.showClientCreditDetails == showClientCreditDetails;
  }

  @override
  int get hashCode =>
      Object.hash(allowInvoicing, allowCreditInvoicing, showClientCreditDetails);
}

class BaseUserRole {
  final String name;
  final List<String> access;
  final RoleCapabilities capabilities;

  BaseUserRole({
    required this.name,
    required this.access,
    this.capabilities = const RoleCapabilities(),
  });

  factory BaseUserRole.fromJson(Map<String, dynamic> json) {
    return BaseUserRole(
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
      capabilities: RoleCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'access': access,
      'capabilities': capabilities.toJson(),
    };
  }
}

class CreateUserRole extends BaseUserRole {
  CreateUserRole({
    required super.name,
    required super.access,
    super.capabilities,
  });

  factory CreateUserRole.fromJson(Map<String, dynamic> json) {
    return CreateUserRole(
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
      capabilities: RoleCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>?,
      ),
    );
  }
}

class UpdateUserRole {
  final String? name;
  final List<String>? access;
  final RoleCapabilities? capabilities;

  UpdateUserRole({this.name, this.access, this.capabilities});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'access': access,
      'capabilities': capabilities?.toJson(),
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
    super.capabilities,
    required this.createdAt,
    this.updatedAt,
    this.isDefault = false,
  });

  factory UserRoleInDb.fromJson(Map<String, dynamic> json) {
    return UserRoleInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      access: List<String>.from(json['access'] as List),
      capabilities: RoleCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>?,
      ),
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
