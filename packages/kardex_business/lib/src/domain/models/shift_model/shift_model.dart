import 'package:kardex_business/src/domain/models/common/user_info.dart';

enum ShiftStatus {
  open,
  closed;

  String get display {
    switch (this) {
      case ShiftStatus.open:
        return 'Abierto';
      case ShiftStatus.closed:
        return 'Cerrado';
    }
  }
}

class BaseShift {
  final String branchId;
  final String branchName;
  final String docNumber;
  final ShiftStatus status;
  final int initialCash;
  final String openingNotes;
  final UserInfo openedBy;
  final int openedAt;

  // Consolidado de Facturas
  final int invoiceCashTotal;
  final int invoiceTransferTotal;
  final int invoiceCardTotal;
  final int invoiceOtherTotal;
  final int invoiceCashSalesTotal;
  final int invoiceCreditTotal;
  final int invoiceTotal;
  final int invoiceCount;

  // Consolidado de Recibos / Abonos
  final int receiptCashTotal;
  final int receiptTransferTotal;
  final int receiptCardTotal;
  final int receiptOtherTotal;
  final int receiptTotal;
  final int receiptCount;

  // Consolidado de Devoluciones y Notas de Crédito
  final int devolutionTotal;
  final int devolutionCount;
  final int creditNoteTotal;
  final int creditNoteCount;

  // Consolidado de Movimientos Manuales de Caja
  final int cashInTotal;
  final int cashOutTotal;

  // Totales Consolidados y Arqueo
  final int expectedCash;
  final int countedCash;
  final int cashDifference;
  final int totalTransfers;
  final int totalCardsAndOthers;
  final int grandTotal;

  // Auditoría de Cierre
  final String closingNotes;

  const BaseShift({
    required this.branchId,
    this.branchName = '',
    this.docNumber = '',
    this.status = ShiftStatus.open,
    this.initialCash = 0,
    this.openingNotes = '',
    required this.openedBy,
    required this.openedAt,
    this.invoiceCashTotal = 0,
    this.invoiceTransferTotal = 0,
    this.invoiceCardTotal = 0,
    this.invoiceOtherTotal = 0,
    this.invoiceCashSalesTotal = 0,
    this.invoiceCreditTotal = 0,
    this.invoiceTotal = 0,
    this.invoiceCount = 0,
    this.receiptCashTotal = 0,
    this.receiptTransferTotal = 0,
    this.receiptCardTotal = 0,
    this.receiptOtherTotal = 0,
    this.receiptTotal = 0,
    this.receiptCount = 0,
    this.devolutionTotal = 0,
    this.devolutionCount = 0,
    this.creditNoteTotal = 0,
    this.creditNoteCount = 0,
    this.cashInTotal = 0,
    this.cashOutTotal = 0,
    this.expectedCash = 0,
    this.countedCash = 0,
    this.cashDifference = 0,
    this.totalTransfers = 0,
    this.totalCardsAndOthers = 0,
    this.grandTotal = 0,
    this.closingNotes = '',
  });

  factory BaseShift.fromJson(Map<String, dynamic> json) => BaseShift(
        branchId: json['branchId'] as String? ?? '',
        branchName: json['branchName'] as String? ?? '',
        docNumber: json['docNumber'] as String? ?? '',
        status: ShiftStatus.values.firstWhere(
          (e) => e.name == json['status']?.toString().toLowerCase(),
          orElse: () => ShiftStatus.open,
        ),
        initialCash: (json['initialCash'] as num?)?.toInt() ?? 0,
        openingNotes: json['openingNotes'] as String? ?? '',
        openedBy: UserInfo.fromJson(json['openedBy'] as Map<String, dynamic>),
        openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
        invoiceCashTotal: (json['invoiceCashTotal'] as num?)?.toInt() ?? 0,
        invoiceTransferTotal: (json['invoiceTransferTotal'] as num?)?.toInt() ?? 0,
        invoiceCardTotal: (json['invoiceCardTotal'] as num?)?.toInt() ?? 0,
        invoiceOtherTotal: (json['invoiceOtherTotal'] as num?)?.toInt() ?? 0,
        invoiceCashSalesTotal: (json['invoiceCashSalesTotal'] as num?)?.toInt() ?? 0,
        invoiceCreditTotal: (json['invoiceCreditTotal'] as num?)?.toInt() ?? 0,
        invoiceTotal: (json['invoiceTotal'] as num?)?.toInt() ?? 0,
        invoiceCount: (json['invoiceCount'] as num?)?.toInt() ?? 0,
        receiptCashTotal: (json['receiptCashTotal'] as num?)?.toInt() ?? 0,
        receiptTransferTotal: (json['receiptTransferTotal'] as num?)?.toInt() ?? 0,
        receiptCardTotal: (json['receiptCardTotal'] as num?)?.toInt() ?? 0,
        receiptOtherTotal: (json['receiptOtherTotal'] as num?)?.toInt() ?? 0,
        receiptTotal: (json['receiptTotal'] as num?)?.toInt() ?? 0,
        receiptCount: (json['receiptCount'] as num?)?.toInt() ?? 0,
        devolutionTotal: (json['devolutionTotal'] as num?)?.toInt() ?? 0,
        devolutionCount: (json['devolutionCount'] as num?)?.toInt() ?? 0,
        creditNoteTotal: (json['creditNoteTotal'] as num?)?.toInt() ?? 0,
        creditNoteCount: (json['creditNoteCount'] as num?)?.toInt() ?? 0,
        cashInTotal: (json['cashInTotal'] as num?)?.toInt() ?? 0,
        cashOutTotal: (json['cashOutTotal'] as num?)?.toInt() ?? 0,
        expectedCash: (json['expectedCash'] as num?)?.toInt() ?? 0,
        countedCash: (json['countedCash'] as num?)?.toInt() ?? 0,
        cashDifference: (json['cashDifference'] as num?)?.toInt() ?? 0,
        totalTransfers: (json['totalTransfers'] as num?)?.toInt() ?? 0,
        totalCardsAndOthers: (json['totalCardsAndOthers'] as num?)?.toInt() ?? 0,
        grandTotal: (json['grandTotal'] as num?)?.toInt() ?? 0,
        closingNotes: json['closingNotes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'branchName': branchName,
        'docNumber': docNumber,
        'status': status.name,
        'initialCash': initialCash,
        'openingNotes': openingNotes,
        'openedBy': openedBy.toJson(),
        'openedAt': openedAt,
        'invoiceCashTotal': invoiceCashTotal,
        'invoiceTransferTotal': invoiceTransferTotal,
        'invoiceCardTotal': invoiceCardTotal,
        'invoiceOtherTotal': invoiceOtherTotal,
        'invoiceCashSalesTotal': invoiceCashSalesTotal,
        'invoiceCreditTotal': invoiceCreditTotal,
        'invoiceTotal': invoiceTotal,
        'invoiceCount': invoiceCount,
        'receiptCashTotal': receiptCashTotal,
        'receiptTransferTotal': receiptTransferTotal,
        'receiptCardTotal': receiptCardTotal,
        'receiptOtherTotal': receiptOtherTotal,
        'receiptTotal': receiptTotal,
        'receiptCount': receiptCount,
        'devolutionTotal': devolutionTotal,
        'devolutionCount': devolutionCount,
        'creditNoteTotal': creditNoteTotal,
        'creditNoteCount': creditNoteCount,
        'cashInTotal': cashInTotal,
        'cashOutTotal': cashOutTotal,
        'expectedCash': expectedCash,
        'countedCash': countedCash,
        'cashDifference': cashDifference,
        'totalTransfers': totalTransfers,
        'totalCardsAndOthers': totalCardsAndOthers,
        'grandTotal': grandTotal,
        'closingNotes': closingNotes,
      };
}

class CreateShift {
  final String branchId;
  final String branchName;
  final int initialCash;
  final String openingNotes;
  final UserInfo openedBy;

  const CreateShift({
    required this.branchId,
    this.branchName = '',
    this.initialCash = 0,
    this.openingNotes = '',
    required this.openedBy,
  });

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'branchName': branchName,
        'initialCash': initialCash,
        'openingNotes': openingNotes,
        'openedBy': openedBy.toJson(),
      };
}

class CloseShiftRequest {
  final int countedCash;
  final String closingNotes;
  final UserInfo closedBy;

  const CloseShiftRequest({
    required this.countedCash,
    this.closingNotes = '',
    required this.closedBy,
  });

  Map<String, dynamic> toJson() => {
        'countedCash': countedCash,
        'closingNotes': closingNotes,
        'closedBy': closedBy.toJson(),
      };
}

class UpdateShift {
  final String? openingNotes;
  final String? closingNotes;

  const UpdateShift({
    this.openingNotes,
    this.closingNotes,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      if (openingNotes != null) 'openingNotes': openingNotes,
      if (closingNotes != null) 'closingNotes': closingNotes,
    };
    return data;
  }
}

class ShiftPreview extends BaseShift {
  final String id;

  const ShiftPreview({
    required this.id,
    required super.branchId,
    super.branchName,
    super.docNumber,
    super.status,
    super.initialCash,
    super.openingNotes,
    required super.openedBy,
    required super.openedAt,
    super.invoiceCashTotal,
    super.invoiceTransferTotal,
    super.invoiceCardTotal,
    super.invoiceOtherTotal,
    super.invoiceCashSalesTotal,
    super.invoiceCreditTotal,
    super.invoiceTotal,
    super.invoiceCount,
    super.receiptCashTotal,
    super.receiptTransferTotal,
    super.receiptCardTotal,
    super.receiptOtherTotal,
    super.receiptTotal,
    super.receiptCount,
    super.devolutionTotal,
    super.devolutionCount,
    super.creditNoteTotal,
    super.creditNoteCount,
    super.cashInTotal,
    super.cashOutTotal,
    super.expectedCash,
    super.countedCash,
    super.cashDifference,
    super.totalTransfers,
    super.totalCardsAndOthers,
    super.grandTotal,
    super.closingNotes,
  });

  factory ShiftPreview.fromJson(Map<String, dynamic> json) {
    final base = BaseShift.fromJson(json);
    return ShiftPreview(
      id: json['id'] as String? ?? '',
      branchId: base.branchId,
      branchName: base.branchName,
      docNumber: base.docNumber,
      status: base.status,
      initialCash: base.initialCash,
      openingNotes: base.openingNotes,
      openedBy: base.openedBy,
      openedAt: base.openedAt,
      invoiceCashTotal: base.invoiceCashTotal,
      invoiceTransferTotal: base.invoiceTransferTotal,
      invoiceCardTotal: base.invoiceCardTotal,
      invoiceOtherTotal: base.invoiceOtherTotal,
      invoiceCashSalesTotal: base.invoiceCashSalesTotal,
      invoiceCreditTotal: base.invoiceCreditTotal,
      invoiceTotal: base.invoiceTotal,
      invoiceCount: base.invoiceCount,
      receiptCashTotal: base.receiptCashTotal,
      receiptTransferTotal: base.receiptTransferTotal,
      receiptCardTotal: base.receiptCardTotal,
      receiptOtherTotal: base.receiptOtherTotal,
      receiptTotal: base.receiptTotal,
      receiptCount: base.receiptCount,
      devolutionTotal: base.devolutionTotal,
      devolutionCount: base.devolutionCount,
      creditNoteTotal: base.creditNoteTotal,
      creditNoteCount: base.creditNoteCount,
      cashInTotal: base.cashInTotal,
      cashOutTotal: base.cashOutTotal,
      expectedCash: base.expectedCash,
      countedCash: base.countedCash,
      cashDifference: base.cashDifference,
      totalTransfers: base.totalTransfers,
      totalCardsAndOthers: base.totalCardsAndOthers,
      grandTotal: base.grandTotal,
      closingNotes: base.closingNotes,
    );
  }
}

class ShiftInDb extends BaseShift {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserInfo? closedBy;
  final int? closedAt;

  const ShiftInDb({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    this.closedBy,
    this.closedAt,
    required super.branchId,
    super.branchName,
    super.docNumber,
    super.status,
    super.initialCash,
    super.openingNotes,
    required super.openedBy,
    required super.openedAt,
    super.invoiceCashTotal,
    super.invoiceTransferTotal,
    super.invoiceCardTotal,
    super.invoiceOtherTotal,
    super.invoiceCashSalesTotal,
    super.invoiceCreditTotal,
    super.invoiceTotal,
    super.invoiceCount,
    super.receiptCashTotal,
    super.receiptTransferTotal,
    super.receiptCardTotal,
    super.receiptOtherTotal,
    super.receiptTotal,
    super.receiptCount,
    super.devolutionTotal,
    super.devolutionCount,
    super.creditNoteTotal,
    super.creditNoteCount,
    super.cashInTotal,
    super.cashOutTotal,
    super.expectedCash,
    super.countedCash,
    super.cashDifference,
    super.totalTransfers,
    super.totalCardsAndOthers,
    super.grandTotal,
    super.closingNotes,
  });

  factory ShiftInDb.fromJson(Map<String, dynamic> json) {
    final base = BaseShift.fromJson(json);
    return ShiftInDb(
      id: json['id'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((json['createdAt'] as num).toInt()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as num).toInt())
          : null,
      closedBy: json['closedBy'] != null
          ? UserInfo.fromJson(json['closedBy'] as Map<String, dynamic>)
          : null,
      closedAt: (json['closedAt'] as num?)?.toInt(),
      branchId: base.branchId,
      branchName: base.branchName,
      docNumber: base.docNumber,
      status: base.status,
      initialCash: base.initialCash,
      openingNotes: base.openingNotes,
      openedBy: base.openedBy,
      openedAt: base.openedAt,
      invoiceCashTotal: base.invoiceCashTotal,
      invoiceTransferTotal: base.invoiceTransferTotal,
      invoiceCardTotal: base.invoiceCardTotal,
      invoiceOtherTotal: base.invoiceOtherTotal,
      invoiceCashSalesTotal: base.invoiceCashSalesTotal,
      invoiceCreditTotal: base.invoiceCreditTotal,
      invoiceTotal: base.invoiceTotal,
      invoiceCount: base.invoiceCount,
      receiptCashTotal: base.receiptCashTotal,
      receiptTransferTotal: base.receiptTransferTotal,
      receiptCardTotal: base.receiptCardTotal,
      receiptOtherTotal: base.receiptOtherTotal,
      receiptTotal: base.receiptTotal,
      receiptCount: base.receiptCount,
      devolutionTotal: base.devolutionTotal,
      devolutionCount: base.devolutionCount,
      creditNoteTotal: base.creditNoteTotal,
      creditNoteCount: base.creditNoteCount,
      cashInTotal: base.cashInTotal,
      cashOutTotal: base.cashOutTotal,
      expectedCash: base.expectedCash,
      countedCash: base.countedCash,
      cashDifference: base.cashDifference,
      totalTransfers: base.totalTransfers,
      totalCardsAndOthers: base.totalCardsAndOthers,
      grandTotal: base.grandTotal,
      closingNotes: base.closingNotes,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      if (closedBy != null) 'closedBy': closedBy!.toJson(),
      if (closedAt != null) 'closedAt': closedAt,
    });
    return data;
  }
}
