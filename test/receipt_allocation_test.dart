import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/receipt_allocation.dart';
import 'package:kardex_business/kardex_business.dart';

InvoiceInDb _invoice({
  required String id,
  required String docNumber,
  int total = 1000,
  int amountPaid = 0,
  DateTime? createdAt,
}) {
  return InvoiceInDb(
    id: id,
    docNumber: docNumber,
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(name: 'Cliente', group: 'General'),
    paymentType: PaymentType.credit,
    bankReference: '',
    status: InvoiceStatus.open,
    saleItems: const [],
    totalCost: 0,
    invoiceDiscount: 0,
    total: total,
    amountPaid: amountPaid,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: createdAt ?? DateTime(2026, 11, 27),
  );
}

CreditNoteInDb _creditNote({
  required String id,
  required int amount,
  CreditNoteType type = CreditNoteType.amount,
  String docNumber = 'NC-001',
  String invoiceId = '',
  String invoiceDocNumber = '',
}) {
  return CreditNoteInDb(
    id: id,
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(name: 'Cliente', group: 'General'),
    type: type,
    docNumber: docNumber,
    originalInvoiceId: invoiceId,
    originalInvoiceDocNumber: invoiceDocNumber,
    amount: amount,
    status: CreditNoteStatus.confirmed,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: DateTime(2026, 11, 27),
  );
}

void main() {
  group('allocatePartialAbono', () {
    test('aplica nota vinculada solo a su factura y suma el efectivo', () {
      final invoice = _invoice(id: 'inv-1', docNumber: 'F-1');
      final note = _creditNote(
        id: 'cn-1',
        amount: 200,
        type: CreditNoteType.devolution,
        invoiceId: 'inv-1',
        invoiceDocNumber: 'F-1',
      );

      final allocation = allocatePartialAbono(
        invoices: [invoice],
        payments: {'inv-1': 8.0},
        confirmedDevolutions: const [],
        creditNotes: [note],
        usedCreditNotes: [note],
      );

      expect(allocation.isValid, isTrue);
      expect(allocation.totalCashCents, 800);
      expect(allocation.appliedInvoices, hasLength(1));
      expect(allocation.appliedInvoices.single.amountApplied, 1000);
    });

    test('distribuye una nota por monto no vinculada entre varias facturas', () {
      final first = _invoice(
        id: 'inv-1',
        docNumber: 'F-1',
        total: 1000,
        createdAt: DateTime(2026, 11, 1),
      );
      final second = _invoice(
        id: 'inv-2',
        docNumber: 'F-2',
        total: 2000,
        createdAt: DateTime(2026, 11, 2),
      );
      final note = _creditNote(id: 'cn-1', amount: 1500);

      final allocation = allocatePartialAbono(
        invoices: [first, second],
        payments: const {},
        confirmedDevolutions: const [],
        creditNotes: [note],
        usedCreditNotes: [note],
      );

      expect(allocation.isValid, isTrue);
      expect(allocation.totalCashCents, 0);
      expect(allocation.appliedInvoices, hasLength(2));
      expect(
        allocation.appliedInvoices.firstWhere((invoice) => invoice.invoiceId == 'inv-1').amountApplied,
        1000,
      );
      expect(
        allocation.appliedInvoices.firstWhere((invoice) => invoice.invoiceId == 'inv-2').amountApplied,
        500,
      );
    });

    test('rechaza una nota por monto que supera el saldo disponible', () {
      final invoice = _invoice(id: 'inv-1', docNumber: 'F-1', total: 1000);
      final note = _creditNote(id: 'cn-1', amount: 1500);

      final allocation = allocatePartialAbono(
        invoices: [invoice],
        payments: const {},
        confirmedDevolutions: const [],
        creditNotes: [note],
        usedCreditNotes: [note],
      );

      expect(allocation.isValid, isFalse);
      expect(allocation.error, contains('superan el saldo disponible'));
    });

    test('no duplica una nota que coincide por invoiceId y docNumber de otra', () {
      final first = _invoice(id: 'inv-1', docNumber: 'F-1');
      final second = _invoice(id: 'inv-2', docNumber: 'F-2');
      final note = _creditNote(
        id: 'cn-1',
        amount: 500,
        type: CreditNoteType.devolution,
        invoiceId: 'inv-1',
        invoiceDocNumber: 'F-2',
      );

      final allocation = allocatePartialAbono(
        invoices: [first, second],
        payments: const {},
        confirmedDevolutions: const [],
        creditNotes: [note],
        usedCreditNotes: [note],
      );

      expect(allocation.isValid, isTrue);
      expect(allocation.appliedInvoices, hasLength(1));
      expect(allocation.appliedInvoices.single.invoiceId, 'inv-1');
      expect(allocation.appliedInvoices.single.amountApplied, 500);
    });

    test('combina efectivo con una nota por monto no vinculada', () {
      final invoice = _invoice(id: 'inv-1', docNumber: 'F-1', total: 1000);
      final note = _creditNote(id: 'cn-1', amount: 300);

      final allocation = allocatePartialAbono(
        invoices: [invoice],
        payments: {'inv-1': 6.0},
        confirmedDevolutions: const [],
        creditNotes: [note],
        usedCreditNotes: [note],
      );

      expect(allocation.isValid, isTrue);
      expect(allocation.totalCashCents, 600);
      expect(allocation.appliedInvoices.single.amountApplied, 900);
    });

    test('deduplica notas repetidas en las listas de entrada', () {
      final invoice = _invoice(id: 'inv-1', docNumber: 'F-1');
      final note = _creditNote(
        id: 'cn-1',
        amount: 500,
        type: CreditNoteType.devolution,
        invoiceId: 'inv-1',
      );

      final allocation = allocatePartialAbono(
        invoices: [invoice],
        payments: const {},
        confirmedDevolutions: const [],
        creditNotes: [note, note],
        usedCreditNotes: [note, note],
      );

      expect(allocation.isValid, isTrue);
      expect(allocation.appliedInvoices.single.amountApplied, 500);
    });
  });
}
