import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/credit_notes/credit_note_policy.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('calculateCreditNoteLine', () {
    test('5 facturados, devuelve 1', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 1,
        conversionFactor: 1,
        invoiceQuantity: 5,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
      );

      expect(result, isA<CreditNoteLineAmounts>());
      final amounts = result as CreditNoteLineAmounts;
      expect(amounts.quantity, 1);
      expect(amounts.subTotal, 100);
      expect(amounts.total, 100);
      expect(amounts.totalDiscount, 0);
    });

    test('5 facturados, devuelve 5 (línea completa)', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 5,
        conversionFactor: 1,
        invoiceQuantity: 5,
        invoiceSubTotal: 500,
        invoiceTotal: 450,
      );

      final amounts = result as CreditNoteLineAmounts;
      expect(amounts.quantity, 5);
      expect(amounts.subTotal, 500);
      expect(amounts.total, 450);
      expect(amounts.totalDiscount, 50);
    });

    test('6 sobre una línea de 5 se rechaza', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 6,
        conversionFactor: 1,
        invoiceQuantity: 5,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
      );

      expect(result, isA<CreditNoteLineInvalid>());
    });

    test('0.3 lb con factor 4 se rechaza por no ser múltiplo exacto', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 0.3,
        conversionFactor: 4,
        invoiceQuantity: 20,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
      );

      expect(result, isA<CreditNoteLineInvalid>());
    });

    test('0.5 lb con factor 4 se acepta y equivale a 2 base', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 0.5,
        conversionFactor: 4,
        invoiceQuantity: 20,
        invoiceSubTotal: 500,
        invoiceTotal: 450,
      );

      final amounts = result as CreditNoteLineAmounts;
      expect(amounts.quantity, 2);
      expect(amounts.subTotal, 50);
      expect(amounts.total, 45);
      expect(amounts.totalDiscount, 5);
    });

    test('descuento con floor usa división entera', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 1,
        conversionFactor: 1,
        invoiceQuantity: 3,
        invoiceSubTotal: 100,
        invoiceTotal: 90,
      );

      final amounts = result as CreditNoteLineAmounts;
      expect(amounts.subTotal, 33);
      expect(amounts.total, 30);
      expect(amounts.totalDiscount, 3);
    });

    test('una línea que convierte a base 0 se rechaza', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 0.0000000001,
        conversionFactor: 4,
        invoiceQuantity: 20,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
      );

      expect(result, isA<CreditNoteLineInvalid>());
    });

    test('cantidad 0 se omite sin error', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 0,
        conversionFactor: 4,
        invoiceQuantity: 20,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
      );

      expect(result, isA<CreditNoteLineSkipped>());
    });

    test('respeta el acumulado previamente devuelto', () {
      final allowed = calculateCreditNoteLine(
        displayQuantity: 1,
        conversionFactor: 1,
        invoiceQuantity: 5,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
        previouslyReturnedBase: 4,
      );
      final rejected = calculateCreditNoteLine(
        displayQuantity: 2,
        conversionFactor: 1,
        invoiceQuantity: 5,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
        previouslyReturnedBase: 4,
      );

      expect(allowed, isA<CreditNoteLineAmounts>());
      expect((allowed as CreditNoteLineAmounts).quantity, 1);
      expect(rejected, isA<CreditNoteLineInvalid>());
    });

    test('línea ya devuelta por completo se rechaza', () {
      final result = calculateCreditNoteLine(
        displayQuantity: 1,
        conversionFactor: 1,
        invoiceQuantity: 5,
        invoiceSubTotal: 500,
        invoiceTotal: 500,
        previouslyReturnedBase: 5,
      );

      expect(result, isA<CreditNoteLineInvalid>());
    });
  });

  group('generateCreditNoteIdempotencyKey', () {
    test('genera un UUID v4 con formato válido', () {
      final key = generateCreditNoteIdempotencyKey(random: math.Random(7));

      expect(
        key,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('genera llaves distintas', () {
      final first = generateCreditNoteIdempotencyKey();
      final second = generateCreditNoteIdempotencyKey();

      expect(first, isNot(second));
    });
  });

  group('SaleItem.invoiceItemIndex', () {
    SaleItem buildItem({int? invoiceItemIndex}) => SaleItem(
      product: ProductItem(
        id: 'product-1',
        name: 'Producto',
        unitName: 'Unidad',
        brandName: 'Marca',
      ),
      selectedPrice: 0,
      quantity: 1,
      cost: 10,
      price: 20,
      subTotal: 20,
      total: 20,
      invoiceItemIndex: invoiceItemIndex,
    );

    test('serializa el índice cuando está presente', () {
      expect(buildItem(invoiceItemIndex: 2).toJson()['invoiceItemIndex'], 2);
    });

    test('omite el índice cuando es nulo', () {
      expect(buildItem().toJson().containsKey('invoiceItemIndex'), isFalse);
    });

    test('deserializa el índice', () {
      final item = SaleItem.fromJson({
        ...buildItem(invoiceItemIndex: 3).toJson(),
      });

      expect(item.invoiceItemIndex, 3);
    });
  });

  group('CreditNoteStatus y Auditoría', () {
    test('estados tienen display adecuado y parsean correctamente', () {
      expect(CreditNoteStatus.emitted.display, 'Emitida');
      expect(CreditNoteStatus.approved.display, 'Aprobada');
      expect(CreditNoteStatus.rejected.display, 'Rechazada');
    });

    test('serializa y deserializa campos de auditoría', () {
      final now = DateTime.now();
      final note = CreditNoteInDb(
        id: 'cn-1',
        branchId: 'branch-1',
        clientId: 'client-1',
        clientInfo: ClientInfo(name: 'Cliente', group: 'GENERAL'),
        type: CreditNoteType.devolution,
        amount: 500,
        status: CreditNoteStatus.approved,
        createdBy: const UserInfo(id: 'u-1', name: 'Creador'),
        approvedBy: const UserInfo(id: 'u-2', name: 'Aprobador'),
        approvedAt: now,
        rejectedBy: const UserInfo(id: 'u-3', name: 'Rechazador'),
        rejectedAt: now,
        rejectionReason: 'Motivo prueba',
        createdAt: now,
      );

      final json = note.toJson();
      expect(json['status'], 'approved');
      expect(json['approvedBy']['name'], 'Aprobador');
      expect(json['rejectionReason'], 'Motivo prueba');

      final fromJson = CreditNoteInDb.fromJson(json);
      expect(fromJson.status, CreditNoteStatus.approved);
      expect(fromJson.approvedBy?.name, 'Aprobador');
      expect(fromJson.rejectionReason, 'Motivo prueba');
    });
  });
}
