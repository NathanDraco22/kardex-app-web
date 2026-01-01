import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';

enum AdjustExitType { adjust, loss, devolution }

class AdjustExitInDb extends AdjustExit {
  AdjustExitInDb({
    required super.id,
    required super.docNumber,
    required super.branchId,
    required super.description,
    required super.type,
    required super.items,
    required super.createdBy,
    required super.createdAt,
    super.updatedAt,
  });

  factory AdjustExitInDb.fromJson(Map<String, dynamic> json) {
    return AdjustExitInDb(
      id: json['id'] as String,
      docNumber: json['docNumber'] as String,
      branchId: json['branchId'] as String,
      description: json['description'] as String,
      type: AdjustExitType.values.firstWhere((e) => e.name == json['type'] as String),
      items: (json['items'] as List).map((e) => AdjustExitItem.fromJson(e)).toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
    );
  }
}

class CreateAdjustExit {
  final String branchId;
  final String description;
  final AdjustExitType type;
  final List<AdjustExitItem> items;
  final UserInfo createdBy;

  CreateAdjustExit({
    required this.branchId,
    required this.description,
    required this.type,
    required this.items,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'description': description,
      'type': type.name,
      'items': items.map((e) => e.toJson()).toList(),
      'createdBy': createdBy.toJson(),
    };
  }
}

class AdjustExit {
  final String id;
  final String docNumber;
  final String branchId;
  final String description;
  final AdjustExitType type;
  final List<AdjustExitItem> items;
  final UserInfo createdBy;
  final int createdAt;
  final int? updatedAt;

  AdjustExit({
    required this.id,
    this.docNumber = '',
    required this.branchId,
    this.description = '',
    required this.type,
    required this.items,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });
}
