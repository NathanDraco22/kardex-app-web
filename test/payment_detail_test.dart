import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';
import 'package:kardex_app_front/widgets/payment_currency_selector.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('Conversión y PaymentDetail', () {
    test('convierte moneda secundaria a primaria y viceversa en centavos', () {
      // $10.00 a tasa 36.00 = C$ 360.00
      final primaryCents = NumberFormatter.convertSecondaryToPrimaryCents(1000, 36.0);
      expect(primaryCents, 36000);

      // Cambio C$ 60.00 (6000 centavos) a tasa 36.00 = $1.67 (167 centavos)
      final secondaryChangeCents = NumberFormatter.convertPrimaryToSecondaryCents(6000, 36.0);
      expect(secondaryChangeCents, 167);
    });

    test('buildPaymentDetail y formatPaymentChangeLabel con moneda secundaria', () {
      const settings = PaymentCurrencySettings(
        primaryCurrency: AppCurrency.nio,
        secondaryCurrency: AppCurrency.usd,
        exchangeRate: 36.0,
        allowSecondaryCurrencyPayment: true,
      );
      expect(settings.canUseDifferentSecondary, isTrue);

      const disabledSettings = PaymentCurrencySettings(
        primaryCurrency: AppCurrency.nio,
        secondaryCurrency: AppCurrency.usd,
        exchangeRate: 36.0,
      );
      expect(disabledSettings.allowSecondaryCurrencyPayment, isFalse);
      expect(disabledSettings.canUseDifferentSecondary, isFalse);

      final detail = buildPaymentDetail(
        useSecondary: true,
        tenderedCents: 1000,
        changePrimaryCents: 6000,
        settings: settings,
      );

      expect(detail, isNotNull);
      expect(detail!.paidCurrency, AppCurrency.usd);
      expect(detail.tenderedAmount, 1000);
      expect(detail.exchangeRate, 36.0);
      expect(detail.changeAmount, 6000);
      expect(detail.formatTenderedLabel(AppCurrency.nio), r'US$10.00 (T.C. 36.00)');
      expect(detail.formatChangeLabel(AppCurrency.nio), r'C$60.00');

      final label = formatPaymentChangeLabel(
        6000,
        primaryCurrency: AppCurrency.nio,
        secondaryCurrency: AppCurrency.usd,
        exchangeRate: 36.0,
      );
      expect(label, r'C$60.00 (US$1.67)');
    });

    test('buildPaymentDetail retorna null si la tasa de cambio es 0 en secundaria', () {
      const settings = PaymentCurrencySettings(
        primaryCurrency: AppCurrency.nio,
        secondaryCurrency: AppCurrency.usd,
        exchangeRate: 0.0,
      );

      final detail = buildPaymentDetail(
        useSecondary: true,
        tenderedCents: 1000,
        changePrimaryCents: 0,
        settings: settings,
      );

      expect(detail, isNull);
    });

    test('InvoiceInDb y ReceiptInDb mantienen retrocompatibilidad con paymentDetail null', () {
      final baseInvoiceJson = {
        'id': 'inv1',
        'branchId': 'b1',
        'clientId': 'c1',
        'clientInfo': {'name': 'Cliente'},
        'docNumber': 'F-001',
        'saleItems': [],
        'amountPaid': 30000,
        'status': 'paid',
        'paymentType': 'cash',
        'bankReference': '',
        'totalCost': 20000,
        'total': 30000,
        'createdAt': 1700000000000,
        'createdBy': {'id': 'u1', 'name': 'Cajero'},
      };

      final legacyInv = InvoiceInDb.fromJson(baseInvoiceJson);
      expect(legacyInv.paymentDetail, isNull);

      final withDetailInv = InvoiceInDb.fromJson({
        ...baseInvoiceJson,
        'paymentDetail': {
          'paidCurrency': 'USD',
          'tenderedAmount': 1000,
          'exchangeRate': 36.0,
          'changeAmount': 6000,
        },
      });
      expect(withDetailInv.paymentDetail, isNotNull);
      expect(withDetailInv.paymentDetail!.paidCurrency, AppCurrency.usd);
      expect(withDetailInv.paymentDetail!.tenderedAmount, 1000);
      expect(withDetailInv.toJson()['paymentDetail']['changeAmount'], 6000);

      final baseReceiptJson = {
        'id': 'rec1',
        'branchId': 'b1',
        'clientId': 'c1',
        'clientInfo': {'name': 'Cliente'},
        'docNumber': 'R-001',
        'appliedInvoices': [],
        'appliedDevolutions': [],
        'paymentMethod': 'cash',
        'bankReference': '',
        'total': 30000,
        'createdAt': 1700000000000,
        'createdBy': {'id': 'u1', 'name': 'Cajero'},
      };

      final legacyRec = ReceiptInDb.fromJson(baseReceiptJson);
      expect(legacyRec.paymentDetail, isNull);

      final withDetailRec = ReceiptInDb.fromJson({
        ...baseReceiptJson,
        'paymentDetail': {
          'paidCurrency': 'USD',
          'tenderedAmount': 1000,
          'exchangeRate': 36.0,
          'changeAmount': 6000,
        },
      });
      expect(withDetailRec.paymentDetail, isNotNull);
      expect(withDetailRec.paymentDetail!.paidCurrency, AppCurrency.usd);
    });

    test('PaymentResult mapea PaymentType al método del recibo', () {
      expect(
        PaymentResult(method: PaymentType.cash, amountReceived: 100).receiptPaymentMethod,
        PaymentMethod.cash,
      );
      expect(
        PaymentResult(method: PaymentType.card, amountReceived: 100).receiptPaymentMethod,
        PaymentMethod.card,
      );
      expect(
        PaymentResult(method: PaymentType.transfer, amountReceived: 100).receiptPaymentMethod,
        PaymentMethod.transfer,
      );
      expect(
        PaymentResult(method: PaymentType.check, amountReceived: 100).receiptPaymentMethod,
        PaymentMethod.check,
      );
      expect(
        PaymentResult(method: PaymentType.other, amountReceived: 100).receiptPaymentMethod,
        PaymentMethod.other,
      );
    });
  });
}
