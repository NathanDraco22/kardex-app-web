import '../shift_cash_movement_model/shift_cash_movement_model.dart';
import '../shift_model/shift_model.dart';

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

class ShiftArqueoDocument {
  final String id;
  final String docNumber;
  final int amount;
  final String? paymentMethod;
  final String? bankReference;
  final String? status;
  final String? type;
  final String? clientName;
  final int createdAt;
  final String? referenceDocNumber;
  final bool counted;

  const ShiftArqueoDocument({
    required this.id,
    required this.docNumber,
    required this.amount,
    this.paymentMethod,
    this.bankReference,
    this.status,
    this.type,
    this.clientName,
    required this.createdAt,
    this.referenceDocNumber,
    required this.counted,
  });

  factory ShiftArqueoDocument.fromJson(Map<String, dynamic> json) {
    return ShiftArqueoDocument(
      id: json['id']?.toString() ?? '',
      docNumber: json['docNumber']?.toString() ?? '',
      amount: _asInt(json['amount']),
      paymentMethod: json['paymentMethod']?.toString(),
      bankReference: json['bankReference']?.toString(),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      clientName: json['clientName']?.toString(),
      createdAt: _asInt(json['createdAt']),
      referenceDocNumber: json['referenceDocNumber']?.toString(),
      counted: json['counted'] as bool? ?? false,
    );
  }
}

class ShiftArqueoTotals {
  final int invoiceCashTotal;
  final int invoiceTransferTotal;
  final int invoiceCardTotal;
  final int invoiceOtherTotal;
  final int invoiceCashSalesTotal;
  final int invoiceCreditTotal;
  final int invoiceTotal;
  final int invoiceCount;
  final int receiptCashTotal;
  final int receiptTransferTotal;
  final int receiptCardTotal;
  final int receiptOtherTotal;
  final int receiptTotal;
  final int receiptCount;
  final int devolutionTotal;
  final int devolutionCount;
  final int creditNoteTotal;
  final int creditNoteCount;
  final int cashInTotal;
  final int cashOutTotal;
  final int expectedCash;
  final int totalTransfers;
  final int totalCardsAndOthers;
  final int grandTotal;

  const ShiftArqueoTotals({
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
    this.totalTransfers = 0,
    this.totalCardsAndOthers = 0,
    this.grandTotal = 0,
  });

  factory ShiftArqueoTotals.fromJson(Map<String, dynamic> json) {
    return ShiftArqueoTotals(
      invoiceCashTotal: _asInt(json['invoiceCashTotal']),
      invoiceTransferTotal: _asInt(json['invoiceTransferTotal']),
      invoiceCardTotal: _asInt(json['invoiceCardTotal']),
      invoiceOtherTotal: _asInt(json['invoiceOtherTotal']),
      invoiceCashSalesTotal: _asInt(json['invoiceCashSalesTotal']),
      invoiceCreditTotal: _asInt(json['invoiceCreditTotal']),
      invoiceTotal: _asInt(json['invoiceTotal']),
      invoiceCount: _asInt(json['invoiceCount']),
      receiptCashTotal: _asInt(json['receiptCashTotal']),
      receiptTransferTotal: _asInt(json['receiptTransferTotal']),
      receiptCardTotal: _asInt(json['receiptCardTotal']),
      receiptOtherTotal: _asInt(json['receiptOtherTotal']),
      receiptTotal: _asInt(json['receiptTotal']),
      receiptCount: _asInt(json['receiptCount']),
      devolutionTotal: _asInt(json['devolutionTotal']),
      devolutionCount: _asInt(json['devolutionCount']),
      creditNoteTotal: _asInt(json['creditNoteTotal']),
      creditNoteCount: _asInt(json['creditNoteCount']),
      cashInTotal: _asInt(json['cashInTotal']),
      cashOutTotal: _asInt(json['cashOutTotal']),
      expectedCash: _asInt(json['expectedCash']),
      totalTransfers: _asInt(json['totalTransfers']),
      totalCardsAndOthers: _asInt(json['totalCardsAndOthers']),
      grandTotal: _asInt(json['grandTotal']),
    );
  }
}

class ShiftArqueoMeta {
  final String totalsSource;
  final int documentsLimit;
  final bool? truncated;

  const ShiftArqueoMeta({
    required this.totalsSource,
    required this.documentsLimit,
    this.truncated,
  });

  bool get isLive => totalsSource == 'live';

  factory ShiftArqueoMeta.fromJson(Map<String, dynamic> json) {
    return ShiftArqueoMeta(
      totalsSource: json['totalsSource']?.toString() ?? 'live',
      documentsLimit: _asInt(json['documentsLimit']),
      truncated: json['truncated'] as bool?,
    );
  }
}

class ShiftArqueoResponse {
  final ShiftInDb shift;
  final ShiftArqueoTotals totals;
  final List<ShiftCashMovementInDb> cashMovements;
  final List<ShiftArqueoDocument> invoices;
  final List<ShiftArqueoDocument> receipts;
  final List<ShiftArqueoDocument> devolutions;
  final List<ShiftArqueoDocument> creditNotes;
  final ShiftArqueoMeta meta;

  const ShiftArqueoResponse({
    required this.shift,
    required this.totals,
    required this.cashMovements,
    required this.invoices,
    required this.receipts,
    required this.devolutions,
    required this.creditNotes,
    required this.meta,
  });

  int get totalDocumentsCount =>
      invoices.length +
      receipts.length +
      devolutions.length +
      creditNotes.length;

  factory ShiftArqueoResponse.fromJson(Map<String, dynamic> json) {
    List<ShiftArqueoDocument> parseDocs(String key) {
      final raw = json[key] as List<dynamic>? ?? const [];
      return raw
          .map((e) => ShiftArqueoDocument.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final rawMovements = json['cashMovements'] as List<dynamic>? ?? const [];

    return ShiftArqueoResponse(
      shift: ShiftInDb.fromJson(json['shift'] as Map<String, dynamic>),
      totals: ShiftArqueoTotals.fromJson(
        json['totals'] as Map<String, dynamic>? ?? const {},
      ),
      cashMovements: rawMovements
          .map(
            (e) => ShiftCashMovementInDb.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      invoices: parseDocs('invoices'),
      receipts: parseDocs('receipts'),
      devolutions: parseDocs('devolutions'),
      creditNotes: parseDocs('creditNotes'),
      meta: ShiftArqueoMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
