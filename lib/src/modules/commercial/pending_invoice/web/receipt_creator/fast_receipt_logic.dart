import 'package:kardex_business/kardex_business.dart';

class FastReceiptLogic {
  static (CreateReceipt?, String) allocateFastPayment({
    required int paymentAmountCents,
    required List<InvoiceInDb> invoices,
    required List<DevolutionInDb> devolutions,
    List<CreditNoteInDb> creditNotes = const [],
    required ClientInDb client,
    required String branchId,
    required String currentUserId,
    required String currentUserName,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String bankReference = "",
  }) {
    if (paymentAmountCents <= 0 && devolutions.isEmpty && creditNotes.isEmpty) {
      return (null, "Debe existir al menos un monto en efectivo, devoluciones o notas de crédito pendientes para abonar.");
    }

    final totalInvoicesDebt = invoices.fold(0, (sum, inv) => sum + (inv.total - inv.amountPaid));
    final totalDevolutions = devolutions.fold(0, (sum, dev) => sum + dev.total);
    final netInvoicesDebt = totalInvoicesDebt - totalDevolutions;
    final totalCreditNotes = creditNotes.fold(0, (sum, cn) => sum + cn.total);

    if (totalCreditNotes > 0 && totalCreditNotes > netInvoicesDebt) {
      return (
        null,
        "No es posible aplicar las notas de crédito: El importe a favor (${NumberFormatter.convertToMoneyLike(totalCreditNotes)}) supera la deuda pendiente de las facturas seleccionadas (${NumberFormatter.convertToMoneyLike(netInvoicesDebt)}). Seleccione más facturas para aplicar el saldo completo.",
      );
    }

    final sortedInvoices = List<InvoiceInDb>.from(invoices)..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int remainingPayment = paymentAmountCents;
    final appliedInvoices = <AppliedInvoice>[];
    final appliedDevolutions = <AppliedDevolution>[];
    final appliedCreditNotes = <AppliedCreditNote>[];
    String bodySummary = "";

    // Track used credit notes to avoid duplicate application
    final usedCreditNoteIds = <String>{};

    for (var invoice in sortedInvoices) {
      int balanceRemainingCents = invoice.total - invoice.amountPaid;
      if (balanceRemainingCents <= 0) continue;

      int totalAppliedToThisInvoice = 0;

      // 1. Linked devolutions
      final linkedDevolutions = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
      for (var dev in linkedDevolutions) {
        if (balanceRemainingCents <= 0) break;

        final devAmountToApply = dev.total > balanceRemainingCents ? balanceRemainingCents : dev.total;

        if (devAmountToApply > 0) {
          appliedDevolutions.add(
            AppliedDevolution(
              devolutionId: dev.id,
              docNumber: dev.docNumber,
              amountApplied: devAmountToApply,
            ),
          );
          balanceRemainingCents -= devAmountToApply;
          totalAppliedToThisInvoice += devAmountToApply;

          final devAmountDouble = devAmountToApply / 100;
          bodySummary +=
              "• Factura #${invoice.docNumber}: \$${devAmountDouble.toStringAsFixed(2)} (Devolución #${dev.docNumber})\n";
        }
      }

      // 2. Linked credit notes
      final linkedCreditNotes = creditNotes.where(
        (cn) =>
            !usedCreditNoteIds.contains(cn.id) &&
            (cn.invoiceId == invoice.id || (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber)),
      ).toList();

      for (var cn in linkedCreditNotes) {
        if (balanceRemainingCents <= 0) break;

        final cnAmountToApply = cn.total > balanceRemainingCents ? balanceRemainingCents : cn.total;

        if (cnAmountToApply > 0) {
          appliedCreditNotes.add(
            AppliedCreditNote(
              creditNoteId: cn.id,
              docNumber: cn.docNumber,
              amountApplied: cnAmountToApply,
            ),
          );
          usedCreditNoteIds.add(cn.id);
          balanceRemainingCents -= cnAmountToApply;
          totalAppliedToThisInvoice += cnAmountToApply;

          final cnAmountDouble = cnAmountToApply / 100;
          bodySummary +=
              "• Factura #${invoice.docNumber}: \$${cnAmountDouble.toStringAsFixed(2)} (Nota de Crédito #${cn.docNumber})\n";
        }
      }

      // 3. Amount-type unlinked credit notes
      final unlinkedCreditNotes = creditNotes.where(
        (cn) => !usedCreditNoteIds.contains(cn.id) && cn.type == CreditNoteType.monto,
      ).toList();

      for (var cn in unlinkedCreditNotes) {
        if (balanceRemainingCents <= 0) break;

        final cnAmountToApply = cn.total > balanceRemainingCents ? balanceRemainingCents : cn.total;

        if (cnAmountToApply > 0) {
          appliedCreditNotes.add(
            AppliedCreditNote(
              creditNoteId: cn.id,
              docNumber: cn.docNumber,
              amountApplied: cnAmountToApply,
            ),
          );
          usedCreditNoteIds.add(cn.id);
          balanceRemainingCents -= cnAmountToApply;
          totalAppliedToThisInvoice += cnAmountToApply;

          final cnAmountDouble = cnAmountToApply / 100;
          bodySummary +=
              "• Factura #${invoice.docNumber}: \$${cnAmountDouble.toStringAsFixed(2)} (Nota de Crédito #${cn.docNumber})\n";
        }
      }

      // 4. Cash / Payment input
      if (balanceRemainingCents > 0 && remainingPayment > 0) {
        final cashToApply = remainingPayment >= balanceRemainingCents ? balanceRemainingCents : remainingPayment;

        balanceRemainingCents -= cashToApply;
        remainingPayment -= cashToApply;
        totalAppliedToThisInvoice += cashToApply;

        final cashAmountDouble = cashToApply / 100;
        bodySummary += "• Factura #${invoice.docNumber}: \$${cashAmountDouble.toStringAsFixed(2)} (${paymentMethod.display})\n";
      }

      if (totalAppliedToThisInvoice > 0) {
        appliedInvoices.add(
          AppliedInvoice(
            invoiceId: invoice.id,
            docNumber: invoice.docNumber,
            amountApplied: totalAppliedToThisInvoice,
          ),
        );
      }
    }

    final cashUsed = paymentAmountCents - remainingPayment;

    if (appliedInvoices.isEmpty) {
      return (null, "No se aplicó ningún cambio a las facturas actuales.");
    }

    final cashUsedDouble = cashUsed / 100;
    final summary = "Resumen de Aplicación (\$${cashUsedDouble.toStringAsFixed(2)})\n\n$bodySummary";

    final createReceipt = CreateReceipt(
      branchId: branchId,
      clientInfo: ClientInfo(
        name: client.name,
        group: client.group,
        address: client.address,
        phone: client.phone,
        email: client.email,
        cardId: client.cardId,
        location: client.location,
      ),
      clientId: client.id,
      appliedInvoices: appliedInvoices,
      appliedDevolutions: appliedDevolutions,
      appliedCreditNotes: appliedCreditNotes,
      paymentMethod: paymentMethod,
      bankReference: bankReference,
      total: cashUsed,
      createdBy: UserInfo(
        id: currentUserId,
        name: currentUserName,
      ),
    );

    return (createReceipt, summary);
  }
}
