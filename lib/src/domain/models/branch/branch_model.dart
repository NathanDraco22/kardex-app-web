class BaseBranch {
  final String name;
  final String description;

  BaseBranch({
    required this.name,
    this.description = "",
  });

  factory BaseBranch.fromJson(Map<String, dynamic> json) {
    return BaseBranch(
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

class CreateBranch extends BaseBranch {
  CreateBranch({
    required super.name,
    super.description,
  });

  factory CreateBranch.fromJson(Map<String, dynamic> json) {
    return CreateBranch(
      name: json['name'] as String,
      description: json['description'] as String? ?? "",
    );
  }
}

class UpdateBranch {
  final String? name;
  final String? description;

  UpdateBranch({
    this.name,
    this.description,
  });

  factory UpdateBranch.fromJson(Map<String, dynamic> json) {
    return UpdateBranch(
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

class BranchInDb extends BaseBranch {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BranchInDb({
    required this.id,
    required super.name,
    super.description,
    required this.createdAt,
    this.updatedAt,
  });

  factory BranchInDb.fromJson(Map<String, dynamic> json) {
    return BranchInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? "",
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    });
    return data;
  }
}
