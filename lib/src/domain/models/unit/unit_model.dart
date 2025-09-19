class BaseUnit {
  final String name;

  BaseUnit({required this.name});

  factory BaseUnit.fromJson(Map<String, dynamic> json) {
    return BaseUnit(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

class CreateUnit extends BaseUnit {
  CreateUnit({required super.name});

  factory CreateUnit.fromJson(Map<String, dynamic> json) {
    return CreateUnit(
      name: json['name'] as String,
    );
  }
}

class UpdateUnit {
  final String? name;

  UpdateUnit({this.name});

  factory UpdateUnit.fromJson(Map<String, dynamic> json) {
    return UpdateUnit(
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'name': name};
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class UnitInDb extends BaseUnit {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UnitInDb({
    required this.id,
    required super.name,
    required this.createdAt,
    this.updatedAt,
  });

  factory UnitInDb.fromJson(Map<String, dynamic> json) {
    return UnitInDb(
      id: json['id'] as String,
      name: json['name'] as String,
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
