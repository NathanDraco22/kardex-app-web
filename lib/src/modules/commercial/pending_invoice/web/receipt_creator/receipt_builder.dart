import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';

CreateReceipt buildAbonoReceipt({
  required String branchId,
  required ClientInDb client,
  required List<AppliedInvoice> appliedInvoices,
  required List<AppliedDevolution> appliedDevolutions,
  required List<AppliedCreditNote> appliedCreditNotes,
  required PaymentResult? payment,
  required int total,
  required String? shiftId,
  required UserInfo createdBy,
}) {
  return CreateReceipt(
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
    paymentMethod: payment?.receiptPaymentMethod ?? PaymentMethod.cash,
    bankReference: payment?.reference ?? "",
    paymentDetail: payment?.paymentDetail,
    total: total,
    shiftId: shiftId,
    createdBy: createdBy,
  );
}
