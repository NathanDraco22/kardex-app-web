import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';

class FastReceiptLogic {
  static (CreateReceipt?, String) allocateFastPayment({
    required int paymentAmountCents,
    required List<InvoiceInDb> invoices,
    required List<DevolutionInDb> devolutions,
    required ClientInDb client,
    required String branchId,
    required String currentUserId,
    required String currentUserName,
  }) {
    if (paymentAmountCents <= 0 && devolutions.isEmpty) {
      return (null, "Debe existir al menos un monto en efectivo o devoluciones pendientes para abonar.");
    }

    final sortedInvoices = List<InvoiceInDb>.from(invoices)..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    int remainingPayment = paymentAmountCents;
    final appliedInvoices = <AppliedInvoice>[];
    final appliedDevolutions = <AppliedDevolution>[];
    String bodySummary = "";

    for (var invoice in sortedInvoices) {
      int balanceRemainingCents = invoice.total - invoice.amountPaid;
      if (balanceRemainingCents <= 0) continue;

      int totalAppliedToThisInvoice = 0;

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

      if (balanceRemainingCents > 0 && remainingPayment > 0) {
        final cashToApply = remainingPayment >= balanceRemainingCents ? balanceRemainingCents : remainingPayment;

        balanceRemainingCents -= cashToApply;
        remainingPayment -= cashToApply;
        totalAppliedToThisInvoice += cashToApply;

        final cashAmountDouble = cashToApply / 100;
        bodySummary += "• Factura #${invoice.docNumber}: \$${cashAmountDouble.toStringAsFixed(2)} (Efectivo)\n";
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
      paymentMethod: PaymentMethod.cash,
      total: cashUsed,
      createdBy: UserInfo(
        id: currentUserId,
        name: currentUserName,
      ),
    );

    return (createReceipt, summary);
  }
}
