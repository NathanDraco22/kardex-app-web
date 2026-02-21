class BaseClient {
  final String name;
  final String? cardId;
  final String? phone;
  final String? address;
  final String? location;
  final String? email;
  final String group;
  final int balance;
  final int creditLimit;
  final bool isCreditActive;
  final bool isActive;

  BaseClient({
    required this.name,
    this.cardId,
    this.phone,
    this.address,
    this.location,
    this.email,
    this.group = "",
    this.balance = 0,
    this.creditLimit = 0,
    this.isCreditActive = false,
    this.isActive = true,
  });

  factory BaseClient.fromJson(Map json) {
    return BaseClient(
      name: json['name'] as String,
      cardId: json['cardId'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      group: json['group'] as String? ?? "",
      balance: json['balance'] as int? ?? 0,
      creditLimit: json['creditLimit'] as int? ?? 0,
      isCreditActive: json['isCreditActive'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardId': cardId,
      'phone': phone,
      'address': address,
      'location': location,
      'email': email,
      'group': group,
      'balance': balance,
      'creditLimit': creditLimit,
      'isCreditActive': isCreditActive,
      'isActive': isActive,
    };
  }
}

class CreateClient extends BaseClient {
  CreateClient({
    required super.name,
    super.cardId,
    super.phone,
    super.address,
    super.location,
    super.email,
    super.group,
    super.balance,
    super.creditLimit,
    super.isCreditActive,
    super.isActive,
  });

  factory CreateClient.fromJson(Map json) {
    return CreateClient(
      name: json['name'] as String,
      cardId: json['cardId'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      group: json['group'] as String? ?? "",
      balance: json['balance'] as int? ?? 0,
      creditLimit: json['creditLimit'] as int? ?? 0,
      isCreditActive: json['isCreditActive'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class UpdateClient {
  final String? name;
  final String? cardId;
  final String? phone;
  final String? address;
  final String? location;
  final String? email;
  final String? group;
  final bool? isActive;
  final bool? isCreditActive;
  final int? creditLimit;

  UpdateClient({
    this.name,
    this.cardId,
    this.phone,
    this.address,
    this.location,
    this.email,
    this.group,
    this.isActive,
    this.isCreditActive,
    this.creditLimit,
  });

  factory UpdateClient.fromJson(Map json) {
    return UpdateClient(
      name: json['name'] as String?,
      cardId: json['cardId'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      group: json['group'] as String?,
      isActive: json['isActive'] as bool?,
      isCreditActive: json['isCreditActive'] as bool?,
      creditLimit: json['creditLimit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'cardId': cardId,
      'phone': phone,
      'address': address,
      'location': location,
      'email': email,
      'group': group,
      'isActive': isActive,
      'isCreditActive': isCreditActive,
      'creditLimit': creditLimit,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class ClientInDb extends BaseClient {
  final String id;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClientInDb({
    required this.id,
    required super.name,
    super.cardId,
    super.phone,
    super.address,
    super.location,
    super.email,
    super.group,
    super.balance,
    super.creditLimit,
    super.isCreditActive,
    super.isActive,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClientInDb.fromJson(Map json) {
    return ClientInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      cardId: json['cardId'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      group: json['group'] as String? ?? "",
      balance: json['balance'] as int? ?? 0,
      creditLimit: json['creditLimit'] as int? ?? 0,
      isCreditActive: json['isCreditActive'] as bool? ?? false,
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
