class BaseExpenseCategory {
  final String name;
  final String? description;
  final bool isActive;

  BaseExpenseCategory({
    required this.name,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}

class CreateExpenseCategory extends BaseExpenseCategory {
  CreateExpenseCategory({
    required super.name,
    super.description,
    super.isActive,
  });

  factory CreateExpenseCategory.fromJson(Map<String, dynamic> json) {
    return CreateExpenseCategory(
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class UpdateExpenseCategory {
  final String? name;
  final String? description;
  final bool? isActive;

  UpdateExpenseCategory({
    this.name,
    this.description,
    this.isActive,
  });

  factory UpdateExpenseCategory.fromJson(Map<String, dynamic> json) {
    return UpdateExpenseCategory(
      name: json['name'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'description': description,
      'isActive': isActive,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ExpenseCategoryInDb extends BaseExpenseCategory {
  final String id;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpenseCategoryInDb({
    required this.id,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    required super.name,
    super.description,
    super.isActive,
  });

  factory ExpenseCategoryInDb.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryInDb(
      id: json['id'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
