import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/mediator.dart';
import 'package:kardex_business/kardex_business.dart';

InvoiceInDb _invoice({required String id, required String docNumber}) {
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
    total: 1000,
    amountPaid: 0,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: DateTime(2026, 11, 27),
  );
}

CreditNoteInDb _creditNote({
  String id = 'cn-1',
  String invoiceId = 'inv-1',
  String invoiceDocNumber = 'F-2',
}) {
  return CreditNoteInDb(
    id: id,
    branchId: 'branch-1',
    clientId: 'client-1',
    clientInfo: ClientInfo(name: 'Cliente', group: 'General'),
    type: CreditNoteType.devolution,
    docNumber: 'NC-001',
    originalInvoiceId: invoiceId,
    originalInvoiceDocNumber: invoiceDocNumber,
    amount: 500,
    status: CreditNoteStatus.confirmed,
    createdBy: const UserInfo(id: 'u-1', name: 'Cajero'),
    createdAt: DateTime(2026, 11, 27),
  );
}

void main() {
  test('el mediador no duplica notas vinculadas al seleccionar varias facturas', () {
    final controller = ViewController();
    final first = _invoice(id: 'inv-1', docNumber: 'F-1');
    final second = _invoice(id: 'inv-2', docNumber: 'F-2');
    final note = _creditNote(invoiceId: 'inv-1', invoiceDocNumber: 'F-2');
    controller.creditNotes = [note, note];

    controller.addToSelected(first);
    controller.addToSelected(second);

    expect(controller.selectedCreditNotes, hasLength(1));
    expect(controller.selectedCreditNotes.single.id, 'cn-1');
  });

  test('isInSelected y removeFromSelected comparan por id tras una recarga', () {
    final controller = ViewController();
    final original = _invoice(id: 'inv-1', docNumber: 'F-1');
    final reloaded = _invoice(id: 'inv-1', docNumber: 'F-1-RELOADED');

    controller.addToSelected(original);
    expect(controller.isInSelected(reloaded), isTrue);

    controller.removeFromSelected(reloaded);
    expect(controller.selectedInvoices, isEmpty);
    expect(controller.isInSelected(original), isFalse);
  });
}
