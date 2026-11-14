import 'package:kardex_business/src/domain/models/common/user_info.dart';

enum CashMovementType {
  inMovement,
  outMovement;

  String get apiValue {
    switch (this) {
      case CashMovementType.inMovement:
        return 'in';
      case CashMovementType.outMovement:
        return 'out';
    }
  }

  String get display {
    switch (this) {
      case CashMovementType.inMovement:
        return 'Entrada';
      case CashMovementType.outMovement:
        return 'Salida';
    }
  }

  static CashMovementType fromApi(String? value) {
    switch (value?.toLowerCase()) {
      case 'out':
        return CashMovementType.outMovement;
      case 'in':
      default:
        return CashMovementType.inMovement;
    }
  }
}

class BaseShiftCashMovement {
  final String branchId;
  final String shiftId;
  final String docNumber;
  final CashMovementType type;
  final int amount;
  final String reason;
  final bool registerAsExpense;
  final String? expenseCategory;
  final String? expenseId;
  final UserInfo createdBy;
  final bool isDeleted;
  final int? deletedAt;

  const BaseShiftCashMovement({
    required this.branchId,
    required this.shiftId,
    this.docNumber = '',
    required this.type,
    required this.amount,
    required this.reason,
    this.registerAsExpense = false,
    this.expenseCategory,
    this.expenseId,
    required this.createdBy,
    this.isDeleted = false,
    this.deletedAt,
  });

  factory BaseShiftCashMovement.fromJson(Map<String, dynamic> json) =>
      BaseShiftCashMovement(
        branchId: json['branchId'] as String? ?? '',
        shiftId: json['shiftId'] as String? ?? '',
        docNumber: json['docNumber'] as String? ?? '',
        type: CashMovementType.fromApi(json['type'] as String?),
        amount: (json['amount'] as num).toInt(),
        reason: json['reason'] as String? ?? '',
        registerAsExpense: json['registerAsExpense'] as bool? ?? false,
        expenseCategory: json['expenseCategory'] as String?,
        expenseId: json['expenseId'] as String?,
        createdBy: UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>),
        isDeleted: json['isDeleted'] as bool? ?? false,
        deletedAt: (json['deletedAt'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'shiftId': shiftId,
        'docNumber': docNumber,
        'type': type.apiValue,
        'amount': amount,
        'reason': reason,
        'registerAsExpense': registerAsExpense,
        if (expenseCategory != null) 'expenseCategory': expenseCategory,
        if (expenseId != null) 'expenseId': expenseId,
        'createdBy': createdBy.toJson(),
        'isDeleted': isDeleted,
        if (deletedAt != null) 'deletedAt': deletedAt,
      };
}

class CreateShiftCashMovement {
  final String branchId;
  final String shiftId;
  final CashMovementType type;
  final int amount;
  final String reason;
  final bool registerAsExpense;
  final String? expenseCategory;
  final UserInfo createdBy;

  const CreateShiftCashMovement({
    required this.branchId,
    required this.shiftId,
    required this.type,
    required this.amount,
    required this.reason,
    this.registerAsExpense = false,
    this.expenseCategory,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'shiftId': shiftId,
        'type': type.apiValue,
        'amount': amount,
        'reason': reason,
        'registerAsExpense': registerAsExpense,
        if (expenseCategory != null) 'expenseCategory': expenseCategory,
        'createdBy': createdBy.toJson(),
      };
}

class UpdateShiftCashMovement {
  final String? reason;

  const UpdateShiftCashMovement({this.reason});

  Map<String, dynamic> toJson() => {
        if (reason != null) 'reason': reason,
      };
}

class ShiftCashMovementInDb extends BaseShiftCashMovement {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ShiftCashMovementInDb({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required super.branchId,
    required super.shiftId,
    super.docNumber,
    required super.type,
    required super.amount,
    required super.reason,
    super.registerAsExpense,
    super.expenseCategory,
    super.expenseId,
    required super.createdBy,
    super.isDeleted,
    super.deletedAt,
  });

  factory ShiftCashMovementInDb.fromJson(Map<String, dynamic> json) {
    final base = BaseShiftCashMovement.fromJson(json);
    return ShiftCashMovementInDb(
      id: json['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as num).toInt()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as num).toInt())
          : null,
      branchId: base.branchId,
      shiftId: base.shiftId,
      docNumber: base.docNumber,
      type: base.type,
      amount: base.amount,
      reason: base.reason,
      registerAsExpense: base.registerAsExpense,
      expenseCategory: base.expenseCategory,
      expenseId: base.expenseId,
      createdBy: base.createdBy,
      isDeleted: base.isDeleted,
      deletedAt: base.deletedAt,
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
