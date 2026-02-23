import 'dart:convert';
import 'dart:typed_data';

import 'package:kardex_app_front/src/domain/models/common/coordinates.dart';

class BaseBranch {
  final String name;
  final String idCard;
  final String address;
  final String email;
  final String phone;
  final String description;
  Uint8List? image;
  Coordinates? coordinates;

  BaseBranch({
    required this.name,
    required this.idCard,
    required this.address,
    required this.email,
    required this.phone,
    this.description = "",
    this.image,
    this.coordinates,
  });

  factory BaseBranch.fromJson(Map<String, dynamic> json) {
    return BaseBranch(
      name: json['name'] as String,
      idCard: json['idCard'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      image: (json['image'] as String?) == null ? null : base64Decode(json['image']),
      description: json['description'] as String? ?? "",
      coordinates: json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'idCard': idCard,
      'address': address,
      'email': email,
      'phone': phone,
      'image': image != null ? base64Encode(image!) : "",
      'description': description,
      'coordinates': coordinates?.toJson(),
    };
  }
}

class CreateBranch extends BaseBranch {
  CreateBranch({
    required super.name,
    super.description,
    required super.idCard,
    required super.address,
    required super.email,
    required super.phone,
    super.image,
    super.coordinates,
  });

  factory CreateBranch.fromJson(Map<String, dynamic> json) {
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
    return CreateBranch(
      name: json['name'] as String,
      idCard: json['idCard'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      image: (json['image'] as String?) == null ? null : base64Decode(json['image']),
      description: json['description'] as String? ?? "",
      coordinates: coordinates,
    );
  }
}

class UpdateBranch {
  String? name;
  String? idCard;
  String? address;
  String? email;
  String? phone;
  String? description;
  String? image;
  Coordinates? coordinates;

  UpdateBranch({
    this.name,
    this.description,
    this.idCard,
    this.address,
    this.email,
    this.phone,
    this.image,
    this.coordinates,
  });

  factory UpdateBranch.fromJson(Map<String, dynamic> json) {
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
    return UpdateBranch(
      name: json['name'] as String?,
      description: json['description'] as String?,
      idCard: json['idCard'] as String?,
      address: json['address'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'idCard': idCard,
      'address': address,
      'email': email,
      'phone': phone,
      'image': image,
      'coordinates': coordinates?.toJson(),
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
    required super.idCard,
    required super.address,
    required super.email,
    required super.phone,
    super.image,
    super.coordinates,
  });

  factory BranchInDb.fromJson(Map<String, dynamic> json) {
    return BranchInDb(
      id: json['id'] as String,
      name: json['name'] as String,
      idCard: json['idCard'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      image: (json['image'] as String?) == null ? null : base64Decode(json['image']),
      coordinates: json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null,
      description: json['description'] as String? ?? "",
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
