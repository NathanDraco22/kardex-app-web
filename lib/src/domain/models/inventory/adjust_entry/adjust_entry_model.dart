import 'package:kardex_app_front/src/domain/models/common/entry_items.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

class BaseAdjustEntry {
  final String docNumber;
  final String branchId;
  final String description;
  final List<EntryItem> items;
  final UserInfo createdBy;

  BaseAdjustEntry({
    this.docNumber = "",
    required this.branchId,
    this.description = "",
    required this.items,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'docNumber': docNumber,
      'branchId': branchId,
      'description': description,
      'items': items.map((e) => e.toJson()).toList(),
      'createdBy': createdBy.toJson(),
    };
  }
}

class CreateAdjustEntry extends BaseAdjustEntry {
  CreateAdjustEntry({
    super.docNumber = "",
    required super.branchId,
    super.description = "",
    required super.items,
    required super.createdBy,
  });

  factory CreateAdjustEntry.fromJson(Map<String, dynamic> json) {
    return CreateAdjustEntry(
      docNumber: json['docNumber'] as String? ?? "",
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List).map((e) => EntryItem.fromJson(e)).toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }
}

class UpdateAdjustEntry {
  // Empty as per pydantic model provided
  UpdateAdjustEntry();
  Map<String, dynamic> toJson() => {};
}

class AdjustEntryInDb extends BaseAdjustEntry {
  final String id;
  final int createdAt;
  final int? updatedAt;

  AdjustEntryInDb({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    super.docNumber,
    required super.branchId,
    super.description,
    required super.items,
    required super.createdBy,
  });

  factory AdjustEntryInDb.fromJson(Map<String, dynamic> json) {
    return AdjustEntryInDb(
      id: json['id'] as String,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      docNumber: json['docNumber'] as String? ?? "",
      branchId: json['branchId'] as String,
      description: json['description'] as String? ?? "",
      items: (json['items'] as List).map((e) => EntryItem.fromJson(e)).toList(),
      createdBy: UserInfo.fromJson(json['createdBy']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    });
    return data;
  }
}
