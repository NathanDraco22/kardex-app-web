import 'package:kardex_business/kardex_business.dart';

class PartialAbonoAllocation {
  final List<AppliedInvoice> appliedInvoices;
  final int totalCashCents;
  final String? error;

  const PartialAbonoAllocation({
    required this.appliedInvoices,
    required this.totalCashCents,
    this.error,
  });

  bool get isValid => error == null;
}

/// Distribuye el efectivo, las devoluciones, las notas vinculadas y las notas
/// por monto no vinculadas entre las facturas seleccionadas.
///
/// Las notas por monto no tienen factura asociada; se aplican a las facturas
/// con saldo disponible en orden de antigüedad, igual que en el abono rápido.
PartialAbonoAllocation allocatePartialAbono({
  required List<InvoiceInDb> invoices,
  required Map<String, double> payments,
  required List<DevolutionInDb> confirmedDevolutions,
  required List<CreditNoteInDb> creditNotes,
  required List<CreditNoteInDb> usedCreditNotes,
}) {
  final appliedByInvoice = <String, int>{};
  final linkedCreditNoteIds = <String>{};

  final uniqueCreditNotes = <String, CreditNoteInDb>{};
  for (var creditNote in creditNotes) {
    uniqueCreditNotes.putIfAbsent(creditNote.id, () => creditNote);
  }

  final linkedNotesByInvoice = <String, List<CreditNoteInDb>>{};
  for (var creditNote in uniqueCreditNotes.values) {
    InvoiceInDb? target;
    if (creditNote.invoiceId.isNotEmpty) {
      for (var invoice in invoices) {
        if (invoice.id == creditNote.invoiceId) {
          target = invoice;
          break;
        }
      }
    } else if (creditNote.invoiceDocNumber.isNotEmpty) {
      for (var invoice in invoices) {
        if (invoice.docNumber == creditNote.invoiceDocNumber) {
          target = invoice;
          break;
        }
      }
    }

    if (target != null) {
      linkedCreditNoteIds.add(creditNote.id);
      linkedNotesByInvoice.putIfAbsent(target.id, () => []).add(creditNote);
    }
  }

  for (var invoice in invoices) {
    final cashInputCents = ((payments[invoice.id] ?? 0.0) * 100).round();
    final seenDevolutionIds = <String>{};
    final linkedDevolutions = confirmedDevolutions
        .where(
          (devolution) => devolution.originalInvoiceId == invoice.id && seenDevolutionIds.add(devolution.id),
        )
        .toList();
    final linkedDevolutionTotal = linkedDevolutions.fold(
      0,
      (sum, devolution) => sum + devolution.total,
    );

    final linkedCreditNotes = linkedNotesByInvoice[invoice.id] ?? const [];
    final linkedCreditNoteTotal = linkedCreditNotes.fold(
      0,
      (sum, creditNote) => sum + creditNote.total,
    );

    appliedByInvoice[invoice.id] = cashInputCents + linkedDevolutionTotal + linkedCreditNoteTotal;
  }

  final unlinkedAmountNotes = <CreditNoteInDb>[];
  final seenCreditNoteIds = <String>{};
  for (var creditNote in usedCreditNotes) {
    if (creditNote.type != CreditNoteType.monto) continue;
    if (linkedCreditNoteIds.contains(creditNote.id)) continue;
    if (!seenCreditNoteIds.add(creditNote.id)) continue;
    unlinkedAmountNotes.add(creditNote);
  }

  final totalUnlinkedNotes = unlinkedAmountNotes.fold(
    0,
    (sum, creditNote) => sum + creditNote.total,
  );

  if (totalUnlinkedNotes > 0) {
    final totalAvailable = invoices.fold<int>(0, (sum, invoice) {
      final balance = invoice.total - invoice.amountPaid;
      final applied = appliedByInvoice[invoice.id] ?? 0;
      final remaining = balance - applied;
      return sum + (remaining > 0 ? remaining : 0);
    });

    if (totalUnlinkedNotes > totalAvailable) {
      return PartialAbonoAllocation(
        appliedInvoices: const [],
        totalCashCents: 0,
        error:
            "Las notas de crédito por monto (${NumberFormatter.convertToMoneyLike(totalUnlinkedNotes)}) "
            "superan el saldo disponible de las facturas seleccionadas "
            "(${NumberFormatter.convertToMoneyLike(totalAvailable)}). "
            "Seleccione más facturas o use Liquidar.",
      );
    }

    final sortedInvoices = List<InvoiceInDb>.from(invoices)..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (var creditNote in unlinkedAmountNotes) {
      var remaining = creditNote.total;
      for (var invoice in sortedInvoices) {
        if (remaining <= 0) break;
        final applied = appliedByInvoice[invoice.id] ?? 0;
        final balance = invoice.total - invoice.amountPaid;
        final capacity = balance - applied;
        if (capacity <= 0) continue;

        final take = remaining < capacity ? remaining : capacity;
        appliedByInvoice[invoice.id] = applied + take;
        remaining -= take;
      }

      if (remaining > 0) {
        return PartialAbonoAllocation(
          appliedInvoices: const [],
          totalCashCents: 0,
          error:
              "La nota de crédito por monto #${creditNote.docNumber} no pudo "
              "aplicarse al saldo disponible de las facturas seleccionadas.",
        );
      }
    }
  }

  final appliedInvoices = <AppliedInvoice>[];
  var totalCashCents = 0;
  for (var invoice in invoices) {
    final amountApplied = appliedByInvoice[invoice.id] ?? 0;
    if (amountApplied > 0) {
      appliedInvoices.add(
        AppliedInvoice(
          invoiceId: invoice.id,
          docNumber: invoice.docNumber,
          amountApplied: amountApplied,
        ),
      );
    }
    totalCashCents += ((payments[invoice.id] ?? 0.0) * 100).round();
  }

  return PartialAbonoAllocation(
    appliedInvoices: appliedInvoices,
    totalCashCents: totalCashCents,
  );
}
