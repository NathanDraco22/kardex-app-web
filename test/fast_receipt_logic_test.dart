import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/fast_receipt_logic.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  test('el abono rápido conserva recibido y cambio en el recibo', () {
    final client = ClientInDb(
      id: 'client-1',
      name: 'Cliente Demo',
      group: 'General',
      createdAt: DateTime(2026, 11, 27),
    );
    final invoice = InvoiceInDb(
      id: 'inv-1',
      docNumber: 'FAC-001',
      branchId: 'branch-1',
      clientId: client.id,
      clientInfo: ClientInfo(name: client.name, group: client.group),
      paymentType: PaymentType.credit,
      bankReference: '',
      status: InvoiceStatus.open,
      saleItems: const [],
      totalCost: 50000,
      invoiceDiscount: 0,
      total: 100000,
      amountPaid: 0,
      createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      createdAt: DateTime(2026, 11, 27),
    );

    final (receipt, summary) = FastReceiptLogic.allocateFastPayment(
      paymentAmountCents: 30000,
      invoices: [invoice],
      devolutions: const [],
      creditNotes: const [],
      client: client,
      branchId: 'branch-1',
      currentUserId: 'u-1',
      currentUserName: 'Cajero',
      paymentDetail: const PaymentDetail(
        paidCurrency: AppCurrency.nio,
        tenderedAmount: 50000,
        exchangeRate: 1.0,
        changeAmount: 20000,
      ),
    );

    expect(receipt, isNotNull, reason: summary);
    expect(receipt!.total, 30000);
    expect(receipt.paymentDetail, isNotNull);
    expect(receipt.paymentDetail!.tenderedAmount, 50000);
    expect(receipt.paymentDetail!.changeAmount, 20000);
    expect(receipt.appliedInvoices.single.amountApplied, 30000);
  });
}
