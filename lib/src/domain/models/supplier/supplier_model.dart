class BaseSupplier {
  final String name;
  final String? cardId;
  final String? email;
  final String? phone;
  final bool isActive;

  BaseSupplier({
    required this.name,
    this.cardId,
    this.email,
    this.phone,
    this.isActive = true,
  });

  factory BaseSupplier.fromJson(Map json) {
    return BaseSupplier(
      name: json['name'] as String,
      cardId: json['cardId'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardId': cardId,
      'email': email,
      'phone': phone,
      'isActive': isActive,
    };
  }
}

class CreateSupplier extends BaseSupplier {
  CreateSupplier({
    required super.name,
    super.cardId,
    super.email,
    super.phone,
    super.isActive,
  });

  factory CreateSupplier.fromJson(Map json) {
    return CreateSupplier(
      name: json['name'] as String,
      cardId: json['cardId'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class UpdateSupplier {
  final String? name;
  final String? cardId;
  final String? email;
  final String? phone;
  final bool? isActive;

  UpdateSupplier({
    this.name,
    this.cardId,
    this.email,
    this.phone,
    this.isActive,
  });

  factory UpdateSupplier.fromJson(Map<String, dynamic> json) {
    return UpdateSupplier(
      name: json['name'] as String?,
      cardId: json['cardId'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'cardId': cardId,
      'email': email,
      'phone': phone,
      'isActive': isActive,
    };

    data.removeWhere((key, value) => value == null);

    return data;
  }
}

class SupplierInDb extends BaseSupplier {
  final String id;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SupplierInDb({
    required this.id,
    required super.name,
    super.cardId,
    super.email,
    super.phone,
    super.isActive,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupplierInDb.fromJson(Map json) {
    return SupplierInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      cardId: json['cardId'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
