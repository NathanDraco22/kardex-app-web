import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

enum ExpenseStatus { draft, open, paid, partiallyPaid, cancelled }

enum ExpenseType { operative, supplier, tax }

class BaseExpense {
  final String branchId;
  final String docNumber;
  final int amount;
  final String category;
  final String? description;
  final int date;
  final String dateId;
  final ExpenseStatus status;
  final ExpenseType type;
  final String supplierId;
  final bool isActive;
  final int? expirationDate;
  final UserInfo createdBy;
  final int? paidAt;

  BaseExpense({
    required this.branchId,
    this.docNumber = "",
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.dateId,
    required this.status,
    required this.type,
    this.supplierId = "",
    this.isActive = true,
    this.expirationDate,
    required this.createdBy,
    this.paidAt,
  });

  factory BaseExpense.fromJson(Map<String, dynamic> json) {
    return BaseExpense(
      branchId: json['branchId'] as String,
      docNumber: json['docNumber'] as String? ?? "",
      amount: json['amount'] as int,
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] as int,
      dateId: json['dateId'] as String,
      status: ExpenseStatus.values.byName(json['status'].toString()),
      type: ExpenseType.values.byName(json['type'].toString()),
      supplierId: json['supplierId'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? true,
      expirationDate: json['expirationDate'] as int?,
      createdBy: UserInfo.fromJson(json['createdBy']),
      paidAt: json['paidAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'docNumber': docNumber,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'dateId': dateId,
      'status': status.name,
      'type': type.name,
      'supplierId': supplierId,
      'isActive': isActive,
      'expirationDate': expirationDate,
      'createdBy': createdBy.toJson(),
      'paidAt': paidAt,
    };
  }
}

class CreateExpense extends BaseExpense {
  CreateExpense({
    required super.branchId,
    super.docNumber,
    required super.amount,
    required super.category,
    super.description,
    required super.date,
    required super.dateId,
    required super.status,
    required super.type,
    super.supplierId,
    super.isActive,
    super.expirationDate,
    required super.createdBy,
    super.paidAt,
  });

  factory CreateExpense.fromJson(Map<String, dynamic> json) {
    return CreateExpense(
      branchId: json['branchId'] as String,
      docNumber: json['docNumber'] as String? ?? "",
      amount: json['amount'] as int,
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] as int,
      dateId: json['dateId'] as String,
      status: ExpenseStatus.values.byName(json['status'].toString()),
      type: ExpenseType.values.byName(json['type'].toString()),
      supplierId: json['supplierId'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? true,
      expirationDate: json['expirationDate'] as int?,
      createdBy: UserInfo.fromJson(json['createdBy']),
      paidAt: json['paidAt'] as int?,
    );
  }
}

class UpdateExpense {
  final int? amount;
  final String? category;
  final String? description;
  final int? date;
  final String? dateId;
  final ExpenseType? type;
  final String? supplierId;
  final bool? isActive;

  UpdateExpense({
    this.amount,
    this.category,
    this.description,
    this.date,
    this.dateId,
    this.type,
    this.supplierId,
    this.isActive,
  });

  factory UpdateExpense.fromJson(Map<String, dynamic> json) {
    return UpdateExpense(
      amount: json['amount'] as int?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      date: json['date'] as int?,
      dateId: json['dateId'] as String?,
      type: json['type'] != null ? ExpenseType.values.byName(json['type'].toString()) : null,
      supplierId: json['supplierId'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'dateId': dateId,
      'type': type?.name,
      'supplierId': supplierId,
      'isActive': isActive,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class AddToAmountRequest {
  final String expenseId;
  final int amountPaid;

  AddToAmountRequest({
    required this.expenseId,
    required this.amountPaid,
  });

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'amountPaid': amountPaid,
    };
  }
}

class ExpenseInDb extends BaseExpense {
  final String id;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExpenseInDb({
    required this.id,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    required super.branchId,
    super.docNumber,
    required super.amount,
    required super.category,
    super.description,
    required super.date,
    required super.dateId,
    required super.status,
    required super.type,
    super.supplierId,
    super.isActive,
    super.expirationDate,
    required super.createdBy,
    super.paidAt,
  });

  factory ExpenseInDb.fromJson(Map<String, dynamic> json) {
    return ExpenseInDb(
      id: json['id'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
      branchId: json['branchId'] as String,
      docNumber: json['docNumber'] as String? ?? "",
      amount: json['amount'] as int,
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] as int,
      dateId: json['dateId'] as String,
      status: ExpenseStatus.values.byName(json['status'].toString()),
      type: ExpenseType.values.byName(json['type'].toString()),
      supplierId: json['supplierId'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? true,
      expirationDate: json['expirationDate'] as int?,
      createdBy: UserInfo.fromJson(json['createdBy']),
      paidAt: json['paidAt'] as int?,
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
