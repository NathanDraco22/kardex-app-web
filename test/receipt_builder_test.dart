import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/receipt_builder.dart';
import 'package:kardex_business/kardex_business.dart';

ClientInDb _client() {
  return ClientInDb(
    id: 'client-1',
    name: 'Cliente Demo',
    group: 'General',
    address: 'Dirección',
    phone: '88888888',
    createdAt: DateTime(2026, 11, 27),
  );
}

void main() {
  group('buildAbonoReceipt', () {
    test('envía método, referencia y detalle de pago en efectivo', () {
      final receipt = buildAbonoReceipt(
        branchId: 'branch-1',
        client: _client(),
        appliedInvoices: [
          AppliedInvoice(
            invoiceId: 'inv-1',
            docNumber: 'F-1',
            amountApplied: 1000,
          ),
        ],
        appliedDevolutions: const [],
        appliedCreditNotes: const [],
        payment: PaymentResult(
          method: PaymentType.cash,
          amountReceived: 1500,
          paymentDetail: const PaymentDetail(
            paidCurrency: AppCurrency.nio,
            tenderedAmount: 1500,
            exchangeRate: 1.0,
            changeAmount: 500,
          ),
        ),
        total: 1000,
        shiftId: 'shift-1',
        createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      );

      expect(receipt.paymentMethod, PaymentMethod.cash);
      expect(receipt.bankReference, '');
      expect(receipt.paymentDetail, isNotNull);
      expect(receipt.paymentDetail!.tenderedAmount, 1500);
      expect(receipt.paymentDetail!.changeAmount, 500);
      expect(receipt.total, 1000);
      expect(receipt.shiftId, 'shift-1');
      expect(receipt.appliedInvoices.single.amountApplied, 1000);

      final json = receipt.toJson();
      expect(json['paymentMethod'], 'cash');
      expect(json['paymentDetail']['changeAmount'], 500);
    });

    test('envía referencia de tarjeta sin detalle de pago', () {
      final receipt = buildAbonoReceipt(
        branchId: 'branch-1',
        client: _client(),
        appliedInvoices: [
          AppliedInvoice(
            invoiceId: 'inv-1',
            docNumber: 'F-1',
            amountApplied: 1000,
          ),
        ],
        appliedDevolutions: const [],
        appliedCreditNotes: const [],
        payment: PaymentResult(
          method: PaymentType.card,
          amountReceived: 1000,
          reference: 'BAC - 12345',
        ),
        total: 1000,
        shiftId: null,
        createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      );

      expect(receipt.paymentMethod, PaymentMethod.card);
      expect(receipt.bankReference, 'BAC - 12345');
      expect(receipt.paymentDetail, isNull);
      expect(receipt.total, 1000);
    });

    test('sin pago queda en efectivo y sin detalle', () {
      final receipt = buildAbonoReceipt(
        branchId: 'branch-1',
        client: _client(),
        appliedInvoices: const [],
        appliedDevolutions: const [],
        appliedCreditNotes: const [],
        payment: null,
        total: 0,
        shiftId: null,
        createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
      );

      expect(receipt.paymentMethod, PaymentMethod.cash);
      expect(receipt.bankReference, '');
      expect(receipt.paymentDetail, isNull);
      expect(receipt.total, 0);
    });
  });
}
