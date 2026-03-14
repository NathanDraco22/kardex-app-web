import 'package:kardex_app_front/src/domain/models/common/coordinates.dart';

class PersonalReference {
  final String name;
  final String phone;
  final String address;
  final String location;
  final String? email;

  PersonalReference({
    required this.name,
    required this.phone,
    required this.address,
    required this.location,
    this.email,
  });

  factory PersonalReference.fromJson(Map json) {
    return PersonalReference(
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      location: json['location'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'location': location,
      'email': email,
    };
  }
}

class BaseClient {
  final String name;
  final String? cardId;
  final String? phone;
  final String? address;
  final String? location;
  final Coordinates? coordinates;
  final String? email;
  final String group;
  final int balance;
  final int creditLimit;
  final DateTime? lastCreditStart;
  final DateTime? lastReceiptDate;
  final bool isCreditActive;
  final bool isActive;
  final List<PersonalReference> personalReferences;

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
    this.lastCreditStart,
    this.lastReceiptDate,
    this.coordinates,
    this.personalReferences = const [],
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
      lastCreditStart: json['lastCreditStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastCreditStart'] as int)
          : null,
      lastReceiptDate: json['lastReceiptDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastReceiptDate'] as int)
          : null,
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      personalReferences: json['personalReferences'] != null
          ? (json['personalReferences'] as List<dynamic>)
                .map((e) => PersonalReference.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cardId': cardId?.toUpperCase(),
      'phone': phone,
      'address': address,
      'location': location,
      'email': email,
      'group': group,
      'balance': balance,
      'creditLimit': creditLimit,
      'isCreditActive': isCreditActive,
      'isActive': isActive,
      'lastCreditStart': lastCreditStart?.millisecondsSinceEpoch,
      'lastReceiptDate': lastReceiptDate?.millisecondsSinceEpoch,
      'coordinates': coordinates?.toJson(),
      'personalReferences': personalReferences.map((e) => e.toJson()).toList(),
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
    super.coordinates,
    super.personalReferences,
  });

  factory CreateClient.fromJson(Map json) {
    final currentCoordinateValue = json['coordinates'];
    Coordinates? coordinates;
    if (currentCoordinateValue != null) {
      if (currentCoordinateValue is Map<String, dynamic>) {
        coordinates = Coordinates.fromJson(currentCoordinateValue);
      }
    }
    if (currentCoordinateValue is Coordinates) {
      coordinates = currentCoordinateValue;
    }

    final currentPersonalReferencesValue = json['personalReferences'];
    List<PersonalReference> personalReferences = [];
    if (currentPersonalReferencesValue is List<PersonalReference>) {
      personalReferences = currentPersonalReferencesValue;
    } else if (currentPersonalReferencesValue != null) {
      personalReferences = currentPersonalReferencesValue
          .map((e) => PersonalReference.fromJson(e as Map<String, dynamic>))
          .toList();
    }

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
      coordinates: coordinates,
      personalReferences: personalReferences,
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
  final Coordinates? coordinates;
  final List<PersonalReference>? personalReferences;

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
    this.coordinates,
    this.personalReferences,
  });

  factory UpdateClient.fromJson(Map json) {
    final currentCoordinateValue = json['coordinates'];
    Coordinates? coordinates;
    if (currentCoordinateValue != null) {
      if (currentCoordinateValue is Map<String, dynamic>) {
        coordinates = Coordinates.fromJson(currentCoordinateValue);
      }
    }
    if (currentCoordinateValue is Coordinates) {
      coordinates = currentCoordinateValue;
    }

    final currentPersonalReferencesValue = json['personalReferences'];
    List<PersonalReference> personalReferences = [];
    if (currentPersonalReferencesValue is List<PersonalReference>) {
      personalReferences = currentPersonalReferencesValue;
    } else if (currentPersonalReferencesValue != null) {
      personalReferences = currentPersonalReferencesValue
          .map((e) => PersonalReference.fromJson(e as Map<String, dynamic>))
          .toList();
    }

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
      coordinates: coordinates,
      personalReferences: personalReferences,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'cardId': cardId?.toUpperCase(),
      'phone': phone,
      'address': address,
      'location': location,
      'email': email,
      'group': group,
      'isActive': isActive,
      'isCreditActive': isCreditActive,
      'creditLimit': creditLimit,
      'coordinates': coordinates?.toJson(),
      'personalReferences': personalReferences?.map((e) => e.toJson()).toList(),
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
    super.lastCreditStart,
    super.lastReceiptDate,
    super.isActive,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    super.coordinates,
    super.personalReferences,
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
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
      lastReceiptDate: json['lastReceiptDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastReceiptDate'] as int)
          : null,
      lastCreditStart: json['lastCreditStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastCreditStart'] as int)
          : null,
      personalReferences: json['personalReferences'] != null
          ? (json['personalReferences'] as List<dynamic>)
                .map((e) => PersonalReference.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
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
