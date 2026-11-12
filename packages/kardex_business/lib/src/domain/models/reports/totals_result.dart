import 'package:kardex_business/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_business/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_business/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_business/src/domain/models/receipt/receipt_total.dart';
import 'package:kardex_business/src/domain/models/reports/expense_totals.dart';

class TotalsResult {
  TotalsResult({
    required this.branchId,
    required this.receipts,
    required this.detailReceipts,
    required this.invoices,
    required this.detailInvoices,
    this.expenses,
  });

  String branchId;
  List<ReceiptTotal> receipts;
  List<InvoiceTotals> invoices;
  List<InvoiceInDb> detailInvoices;
  List<ReceiptInDb> detailReceipts;
  final ExpenseTotals? expenses;

  factory TotalsResult.fromJson(Map<String, dynamic> map) {
    return TotalsResult(
      branchId: map['branchId'],
      receipts:
          (map['receipts'] as List<dynamic>?)?.map((e) => ReceiptTotal.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      detailReceipts:
          (map['detailReceipts'] as List<dynamic>?)
              ?.map((e) => ReceiptInDb.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      invoices:
          (map['invoices'] as List<dynamic>?)?.map((e) => InvoiceTotals.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      detailInvoices:
          (map['detailInvoices'] as List<dynamic>?)
              ?.map((e) => InvoiceInDb.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expenses: map['expenses'] is Map<String, dynamic>
          ? ExpenseTotals.fromJson(map['expenses'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'receipts': receipts.map((e) => e.toJson()).toList(),
      'detailReceipts': detailReceipts.map((e) => e.toJson()).toList(),
      'invoices': invoices.map((e) => e.toJson()).toList(),
      'detailInvoices': detailInvoices.map((e) => e.toJson()).toList(),
      if (expenses != null) 'expenses': expenses!.toJson(),
    };
  }
}
