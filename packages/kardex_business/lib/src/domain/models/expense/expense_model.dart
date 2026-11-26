import 'package:kardex_business/src/domain/models/common/user_info.dart';

enum ExpenseStatus { draft, open, paid, partiallyPaid, cancelled }

enum ExpenseType { operative, supplier, tax }

enum ExpensePaymentMethod {
  cash,
  transfer,
  card,
  check,
  other;

  String get displayLabel {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return 'Efectivo';
      case ExpensePaymentMethod.transfer:
        return 'Transferencia';
      case ExpensePaymentMethod.card:
        return 'Tarjeta';
      case ExpensePaymentMethod.check:
        return 'Cheque';
      case ExpensePaymentMethod.other:
        return 'Otro';
    }
  }

  static ExpensePaymentMethod fromRaw(Object? raw) {
    final value = raw?.toString() ?? '';
    for (final method in ExpensePaymentMethod.values) {
      if (method.name == value) return method;
    }
    return ExpensePaymentMethod.other;
  }
}

class ExpensePayment {
  final String id;
  final int amount;
  final ExpensePaymentMethod paymentMethod;
  final String? reference;
  final String? note;
  final int paidAt;
  final UserInfo? createdBy;
  final int createdAt;

  const ExpensePayment({
    required this.id,
    required this.amount,
    this.paymentMethod = ExpensePaymentMethod.cash,
    this.reference,
    this.note,
    required this.paidAt,
    this.createdBy,
    required this.createdAt,
  });

  factory ExpensePayment.fromJson(Map<String, dynamic> json) {
    return ExpensePayment(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      paymentMethod: ExpensePaymentMethod.fromRaw(json['paymentMethod']),
      reference: json['reference'] as String?,
      note: json['note'] as String?,
      paidAt: (json['paidAt'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['createdBy'] as Map<String, dynamic>)
          : null,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentMethod': paymentMethod.name,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
      'paidAt': paidAt,
      if (createdBy != null) 'createdBy': createdBy!.toJson(),
      'createdAt': createdAt,
    };
  }
}

class SupplierPayableSummary {
  final String supplierId;
  final String supplierName;
  final int totalAmount;
  final int totalPaid;
  final int pendingAmount;
  final int overdueAmount;
  final int pendingCount;
  final int overdueCount;
  final int? oldestDueDate;

  const SupplierPayableSummary({
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    required this.totalPaid,
    required this.pendingAmount,
    required this.overdueAmount,
    required this.pendingCount,
    required this.overdueCount,
    this.oldestDueDate,
  });

  factory SupplierPayableSummary.fromJson(Map<String, dynamic> json) {
    return SupplierPayableSummary(
      supplierId: json['supplierId'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? 'Proveedor sin nombre',
      totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toInt() ?? 0,
      pendingAmount: (json['pendingAmount'] as num?)?.toInt() ?? 0,
      overdueAmount: (json['overdueAmount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
      overdueCount: (json['overdueCount'] as num?)?.toInt() ?? 0,
      oldestDueDate: (json['oldestDueDate'] as num?)?.toInt(),
    );
  }
}

class AccountsPayableSummary {
  final int totalPending;
  final int totalOverdue;
  final int suppliersCount;
  final int documentsCount;
  final List<SupplierPayableSummary> suppliers;

  const AccountsPayableSummary({
    this.totalPending = 0,
    this.totalOverdue = 0,
    this.suppliersCount = 0,
    this.documentsCount = 0,
    this.suppliers = const [],
  });

  factory AccountsPayableSummary.fromJson(Map<String, dynamic> json) {
    final rawSuppliers = json['suppliers'] as List<dynamic>? ?? const [];
    return AccountsPayableSummary(
      totalPending: (json['totalPending'] as num?)?.toInt() ?? 0,
      totalOverdue: (json['totalOverdue'] as num?)?.toInt() ?? 0,
      suppliersCount: (json['suppliersCount'] as num?)?.toInt() ?? 0,
      documentsCount: (json['documentsCount'] as num?)?.toInt() ?? 0,
      suppliers: rawSuppliers
          .whereType<Map<String, dynamic>>()
          .map(SupplierPayableSummary.fromJson)
          .toList(growable: false),
    );
  }
}

class BaseExpense {
  final String branchId;
  final String docNumber;
  final int amount;
  final int amountPaid;
  final List<ExpensePayment> payments;
  final String category;
  final String? description;
  final int date;
  final String dateId;
  final ExpenseStatus status;
  final ExpenseType type;
  final String supplierId;
  final String supplierName;
  final bool isActive;
  final int? expirationDate;
  final UserInfo createdBy;
  final int? paidAt;
  final String? shiftId;

  int get effectiveAmountPaid => status == ExpenseStatus.paid ? amount : amountPaid.clamp(0, amount);

  int get remainingAmount =>
      status == ExpenseStatus.cancelled ? 0 : (amount - effectiveAmountPaid).clamp(0, amount);

  BaseExpense({
    required this.branchId,
    this.docNumber = "",
    required this.amount,
    this.amountPaid = 0,
    this.payments = const [],
    required this.category,
    this.description,
    required this.date,
    required this.dateId,
    required this.status,
    required this.type,
    this.supplierId = "",
    this.supplierName = "",
    this.isActive = true,
    this.expirationDate,
    required this.createdBy,
    this.paidAt,
    this.shiftId,
  });

  factory BaseExpense.fromJson(Map<String, dynamic> json) {
    final rawPayments = json['payments'] as List<dynamic>? ?? const [];
    return BaseExpense(
      branchId: json['branchId'] as String,
      docNumber: json['docNumber'] as String? ?? "",
      amount: json['amount'] as int,
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      payments: rawPayments
          .whereType<Map<String, dynamic>>()
          .map(ExpensePayment.fromJson)
          .toList(growable: false),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] as int,
      dateId: json['dateId'] as String,
      status: ExpenseStatus.values.byName(json['status'].toString()),
      type: ExpenseType.values.byName(json['type'].toString()),
      supplierId: json['supplierId'] as String? ?? "",
      supplierName: json['supplierName'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? true,
      expirationDate: json['expirationDate'] as int?,
      createdBy: UserInfo.fromJson(json['createdBy']),
      paidAt: json['paidAt'] as int?,
      shiftId: json['shiftId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'docNumber': docNumber,
      'amount': amount,
      'amountPaid': amountPaid,
      'payments': payments.map((p) => p.toJson()).toList(growable: false),
      'category': category,
      'description': description,
      'date': date,
      'dateId': dateId,
      'status': status.name,
      'type': type.name,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'isActive': isActive,
      'expirationDate': expirationDate,
      'createdBy': createdBy.toJson(),
      'paidAt': paidAt,
      if (shiftId != null) 'shiftId': shiftId,
    };
  }
}

class CreateExpense extends BaseExpense {
  CreateExpense({
    required super.branchId,
    super.docNumber,
    required super.amount,
    super.amountPaid,
    super.payments,
    required super.category,
    super.description,
    required super.date,
    required super.dateId,
    required super.status,
    required super.type,
    super.supplierId,
    super.supplierName,
    super.isActive,
    super.expirationDate,
    required super.createdBy,
    super.paidAt,
    super.shiftId,
  });

  factory CreateExpense.fromJson(Map<String, dynamic> json) {
    final rawPayments = json['payments'] as List<dynamic>? ?? const [];
    return CreateExpense(
      branchId: json['branchId'] as String,
      docNumber: json['docNumber'] as String? ?? "",
      amount: json['amount'] as int,
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      payments: rawPayments
          .whereType<Map<String, dynamic>>()
          .map(ExpensePayment.fromJson)
          .toList(growable: false),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] as int,
      dateId: json['dateId'] as String,
      status: ExpenseStatus.values.byName(json['status'].toString()),
      type: ExpenseType.values.byName(json['type'].toString()),
      supplierId: json['supplierId'] as String? ?? "",
      supplierName: json['supplierName'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? true,
      expirationDate: json['expirationDate'] as int?,
      createdBy: UserInfo.fromJson(json['createdBy']),
      paidAt: json['paidAt'] as int?,
      shiftId: json['shiftId'] as String?,
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
  final String? supplierName;
  final bool? isActive;
  final ExpenseStatus? status;
  final int? expirationDate;

  UpdateExpense({
    this.amount,
    this.category,
    this.description,
    this.date,
    this.dateId,
    this.type,
    this.supplierId,
    this.supplierName,
    this.isActive,
    this.status,
    this.expirationDate,
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
      supplierName: json['supplierName'] as String?,
      isActive: json['isActive'] as bool?,
      status: json['status'] != null ? ExpenseStatus.values.byName(json['status'].toString()) : null,
      expirationDate: json['expirationDate'] as int?,
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
      'supplierName': supplierName,
      'isActive': isActive,
      'status': status?.name,
      'expirationDate': expirationDate,
    };
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class AddToAmountRequest {
  final String expenseId;
  final int amountPaid;
  final ExpensePaymentMethod paymentMethod;
  final String? reference;
  final String? note;
  final int? paidAt;
  final UserInfo? createdBy;

  AddToAmountRequest({
    required this.expenseId,
    required this.amountPaid,
    this.paymentMethod = ExpensePaymentMethod.cash,
    this.reference,
    this.note,
    this.paidAt,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'amountPaid': amountPaid,
      'paymentMethod': paymentMethod.name,
      if (reference != null && reference!.trim().isNotEmpty) 'reference': reference!.trim(),
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
      if (paidAt != null) 'paidAt': paidAt,
      if (createdBy != null) 'createdBy': createdBy!.toJson(),
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
    super.amountPaid,
    super.payments,
    required super.category,
    super.description,
    required super.date,
    required super.dateId,
    required super.status,
    required super.type,
    super.supplierId,
    super.supplierName,
    super.isActive,
    super.expirationDate,
    required super.createdBy,
    super.paidAt,
    super.shiftId,
  });

  factory ExpenseInDb.fromJson(Map<String, dynamic> json) {
    final rawPayments = json['payments'] as List<dynamic>? ?? const [];
    return ExpenseInDb(
      id: json['id'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int) : null,
      branchId: json['branchId'] as String,
      docNumber: json['docNumber'] as String? ?? "",
      amount: json['amount'] as int,
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      payments: rawPayments
          .whereType<Map<String, dynamic>>()
          .map(ExpensePayment.fromJson)
          .toList(growable: false),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] as int,
      dateId: json['dateId'] as String,
      status: ExpenseStatus.values.byName(json['status'].toString()),
      type: ExpenseType.values.byName(json['type'].toString()),
      supplierId: json['supplierId'] as String? ?? "",
      supplierName: json['supplierName'] as String? ?? "",
      isActive: json['isActive'] as bool? ?? true,
      expirationDate: json['expirationDate'] as int?,
      createdBy: UserInfo.fromJson(json['createdBy']),
      paidAt: json['paidAt'] as int?,
      shiftId: json['shiftId'] as String?,
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
