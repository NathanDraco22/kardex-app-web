import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/devolutions/devolution_eligibility.dart';
import 'package:kardex_business/kardex_business.dart';

InvoiceInDb _makeInvoice({
  PaymentType paymentType = PaymentType.cash,
  InvoiceStatus status = InvoiceStatus.paid,
  int total = 1000,
  int amountPaid = 1000,
  int invoiceDiscount = 0,
  String clientId = kSaleClientId,
  List<SaleItem> saleItems = const [],
}) {
  return InvoiceInDb(
    id: 'inv-1',
    docNumber: 'FAC-001',
    branchId: 'branch-1',
    clientId: clientId,
    clientInfo: ClientInfo(name: 'Cliente', group: 'General'),
    paymentType: paymentType,
    bankReference: '',
    status: status,
    saleItems: saleItems,
    totalCost: 500,
    invoiceDiscount: invoiceDiscount,
    total: total,
    amountPaid: amountPaid,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: DateTime(2026, 11, 27),
  );
}

SaleItem _makeSaleItem({
  String productId = 'prod-1',
  int quantity = 3,
  int? invoiceItemIndex,
}) {
  return SaleItem(
    product: ProductItem(
      id: productId,
      name: 'Producto $productId',
      unitName: 'Unidad',
    ),
    selectedPrice: 100,
    quantity: quantity,
    cost: 50,
    price: 100,
    subTotal: quantity * 100,
    total: quantity * 100,
    invoiceItemIndex: invoiceItemIndex,
  );
}

DevolutionInDb _makeDevolution({
  required DevolutionStatus status,
  required List<SaleItem> returnedItems,
  String? originalInvoicePaymentType,
}) {
  return DevolutionInDb(
    id: 'dev-${status.name}',
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(name: 'Cliente', group: 'General'),
    docNumber: 'DEV-001',
    originalInvoiceId: 'inv-1',
    originalInvoiceDocNumber: 'FAC-001',
    originalInvoicePaymentType: originalInvoicePaymentType,
    returnedItems: returnedItems,
    description: 'Motivo de prueba suficientemente largo',
    status: status,
    totalCost: 50,
    total: 100,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: DateTime(2026, 11, 27),
  );
}

CreditNoteInDb _makeCreditNote({
  required CreditNoteStatus status,
  required List<SaleItem> returnedItems,
}) {
  return CreditNoteInDb(
    id: 'cn-${status.name}',
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(name: 'Cliente', group: 'General'),
    docNumber: 'NC-001',
    type: CreditNoteType.devolution,
    originalInvoiceId: 'inv-1',
    originalInvoiceDocNumber: 'FAC-001',
    returnedItems: returnedItems,
    amount: 100,
    status: status,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: DateTime(2026, 11, 27),
  );
}

void main() {
  group('validateInvoiceForDevolution', () {
    test('permite factura de contado de consumidor final', () {
      final inv = _makeInvoice(
        paymentType: PaymentType.cash,
        status: InvoiceStatus.paid,
        amountPaid: 1000,
      );
      expect(validateInvoiceForDevolution(inv), isNull);
    });

    test('permite factura de contado de cliente registrado', () {
      final inv = _makeInvoice(
        paymentType: PaymentType.transfer,
        status: InvoiceStatus.paid,
        amountPaid: 1000,
        clientId: 'client-1',
      );
      expect(validateInvoiceForDevolution(inv), isNull);
    });

    test('permite factura a crédito sin abonos (open y amountPaid == 0)', () {
      final inv = _makeInvoice(
        paymentType: PaymentType.credit,
        status: InvoiceStatus.open,
        amountPaid: 0,
        clientId: 'client-1',
      );
      expect(validateInvoiceForDevolution(inv), isNull);
    });

    test('bloquea factura a crédito con abono parcial', () {
      final inv = _makeInvoice(
        paymentType: PaymentType.credit,
        status: InvoiceStatus.partiallypaid,
        amountPaid: 300,
        clientId: 'client-1',
      );
      expect(validateInvoiceForDevolution(inv), isNotNull);
    });

    test('bloquea factura a crédito pagada', () {
      final inv = _makeInvoice(
        paymentType: PaymentType.credit,
        status: InvoiceStatus.paid,
        amountPaid: 1000,
        clientId: 'client-1',
      );
      expect(validateInvoiceForDevolution(inv), isNotNull);
    });

    test('bloquea factura cancelada y con descuento global', () {
      expect(
        validateInvoiceForDevolution(_makeInvoice(status: InvoiceStatus.cancelled)),
        isNotNull,
      );
      expect(
        validateInvoiceForDevolution(_makeInvoice(invoiceDiscount: 50)),
        isNotNull,
      );
    });
  });

  group('computePreviouslyReturnedByLine', () {
    test('suma devoluciones y notas de crédito activas e ignora canceladas/rechazadas', () {
      final saleItems = [
        _makeSaleItem(productId: 'prod-1', quantity: 5),
        _makeSaleItem(productId: 'prod-2', quantity: 2),
      ];

      final devolutions = [
        _makeDevolution(
          status: DevolutionStatus.confirmed,
          returnedItems: [_makeSaleItem(productId: 'prod-1', quantity: 1, invoiceItemIndex: 0)],
        ),
        _makeDevolution(
          status: DevolutionStatus.open,
          returnedItems: [_makeSaleItem(productId: 'prod-1', quantity: 1)], // legacy sin index
        ),
        _makeDevolution(
          status: DevolutionStatus.cancelled,
          returnedItems: [_makeSaleItem(productId: 'prod-1', quantity: 3, invoiceItemIndex: 0)],
        ),
      ];

      final creditNotes = [
        _makeCreditNote(
          status: CreditNoteStatus.approved,
          returnedItems: [_makeSaleItem(productId: 'prod-1', quantity: 2, invoiceItemIndex: 0)],
        ),
        _makeCreditNote(
          status: CreditNoteStatus.rejected,
          returnedItems: [_makeSaleItem(productId: 'prod-2', quantity: 2, invoiceItemIndex: 1)],
        ),
        _makeCreditNote(
          status: CreditNoteStatus.cancelled,
          returnedItems: [_makeSaleItem(productId: 'prod-2', quantity: 2, invoiceItemIndex: 1)],
        ),
      ];

      final result = computePreviouslyReturnedByLine(
        saleItems: saleItems,
        devolutions: devolutions,
        creditNotes: creditNotes,
      );

      expect(result[0], 4);
      expect(result[1], isNull);
    });
  });

  group('DevolutionInDb originalInvoicePaymentType', () {
    test('serializa y deserializa originalInvoicePaymentType', () {
      final dev = _makeDevolution(
        status: DevolutionStatus.confirmed,
        returnedItems: [_makeSaleItem(invoiceItemIndex: 0)],
        originalInvoicePaymentType: 'credit',
      );
      final json = dev.toJson();
      expect(json['originalInvoicePaymentType'], 'credit');

      final parsed = DevolutionInDb.fromJson(json);
      expect(parsed.originalInvoicePaymentType, 'credit');
    });
  });
}
