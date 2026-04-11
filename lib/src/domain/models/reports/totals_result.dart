import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_total.dart';

class TotalsResult {
  TotalsResult({
    required this.branchId,
    required this.receipts,
    required this.invoices,
  });

  String branchId;
  List<ReceiptTotal> receipts;
  List<InvoiceTotals> invoices;

  factory TotalsResult.fromJson(Map<String, dynamic> map) {
    return TotalsResult(
      branchId: map['branchId'],
      receipts: (map['receipts'] as List<dynamic>?)
              ?.map((e) => ReceiptTotal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      invoices: (map['invoices'] as List<dynamic>?)
              ?.map((e) => InvoiceTotals.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'receipts': receipts.map((e) => e.toJson()).toList(),
      'invoices': invoices.map((e) => e.toJson()).toList(),
    };
  }
}
