import '../credit_note/credit_note.dart';
import '../devolution/devolution.dart';
import '../invoice/invoice_model.dart';

class PendingCheckoutSummary {
  final int totalInvoices;
  final int totalDevolutions;
  final int totalCreditNotes;
  final int netTotalPayable;

  const PendingCheckoutSummary({
    required this.totalInvoices,
    required this.totalDevolutions,
    required this.totalCreditNotes,
    required this.netTotalPayable,
  });

  factory PendingCheckoutSummary.fromJson(Map<String, dynamic> json) {
    return PendingCheckoutSummary(
      totalInvoices: json['totalInvoices'] as int? ?? 0,
      totalDevolutions: json['totalDevolutions'] as int? ?? 0,
      totalCreditNotes: json['totalCreditNotes'] as int? ?? 0,
      netTotalPayable: json['netTotalPayable'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInvoices': totalInvoices,
      'totalDevolutions': totalDevolutions,
      'totalCreditNotes': totalCreditNotes,
      'netTotalPayable': netTotalPayable,
    };
  }
}

class ClientPendingInvoicesComposite {
  final List<InvoiceInDb> invoices;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final PendingCheckoutSummary summary;

  const ClientPendingInvoicesComposite({
    required this.invoices,
    required this.devolutions,
    required this.creditNotes,
    required this.summary,
  });

  factory ClientPendingInvoicesComposite.fromJson(Map<String, dynamic> json) {
    final rawInvoices = json['invoices'] as List<dynamic>? ?? [];
    final rawDevolutions = json['devolutions'] as List<dynamic>? ?? [];
    final rawCreditNotes = json['creditNotes'] as List<dynamic>? ?? [];

    return ClientPendingInvoicesComposite(
      invoices: rawInvoices
          .map((item) => InvoiceInDb.fromJson(item as Map<String, dynamic>))
          .toList(),
      devolutions: rawDevolutions
          .map((item) => DevolutionInDb.fromJson(item as Map<String, dynamic>))
          .toList(),
      creditNotes: rawCreditNotes
          .map((item) => CreditNoteInDb.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: PendingCheckoutSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoices': invoices.map((e) => e.toJson()).toList(),
      'devolutions': devolutions.map((e) => e.toJson()).toList(),
      'creditNotes': creditNotes.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}
