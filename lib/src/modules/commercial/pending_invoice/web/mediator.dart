import 'package:material_ui/material_ui.dart';
import 'package:kardex_business/kardex_business.dart';

class ViewController extends ChangeNotifier {
  List<InvoiceInDb> _selectedInvoices = [];
  final List<DevolutionInDb> _selectedDevolutions = [];
  final List<CreditNoteInDb> _selectedCreditNotes = [];

  ClientInDb? _selectedClient;

  List<DevolutionInDb> devolutions = [];
  List<CreditNoteInDb> creditNotes = [];

  List<InvoiceInDb> get selectedInvoices => _selectedInvoices;
  ClientInDb? get selectedClient => _selectedClient;
  List<DevolutionInDb> get selectedDevolutions => _selectedDevolutions;
  List<CreditNoteInDb> get selectedCreditNotes => _selectedCreditNotes;

  void changeClient(ClientInDb newClient) {
    _selectedClient = newClient;
    _selectedInvoices = [];
    _selectedDevolutions.clear();
    _selectedCreditNotes.clear();
    notifyListeners();
  }

  bool _isLinkedCreditNote(CreditNoteInDb creditNote, InvoiceInDb invoice) {
    if (creditNote.invoiceId.isNotEmpty) {
      return creditNote.invoiceId == invoice.id;
    }
    return creditNote.invoiceDocNumber.isNotEmpty && creditNote.invoiceDocNumber == invoice.docNumber;
  }

  void _addCreditNote(CreditNoteInDb creditNote) {
    if (_selectedCreditNotes.any((existing) => existing.id == creditNote.id)) {
      return;
    }
    _selectedCreditNotes.add(creditNote);
  }

  void _addDevolution(DevolutionInDb devolution) {
    if (_selectedDevolutions.any((existing) => existing.id == devolution.id)) {
      return;
    }
    _selectedDevolutions.add(devolution);
  }

  void addToSelected(InvoiceInDb invoice) {
    if (!_selectedInvoices.any((existing) => existing.id == invoice.id)) {
      _selectedInvoices.add(invoice);
    }
    final devolutionsMatched = devolutions.where(
      (devolution) => devolution.originalInvoiceId == invoice.id && devolution.status == DevolutionStatus.confirmed,
    );
    for (final devolution in devolutionsMatched) {
      _addDevolution(devolution);
    }

    final creditNotesMatched = creditNotes.where(
      (cn) => _isLinkedCreditNote(cn, invoice),
    );
    for (final creditNote in creditNotesMatched) {
      _addCreditNote(creditNote);
    }

    // Also include amount-type credit notes, linked or unlinked.
    final amountNotes = creditNotes.where(
      (cn) => cn.type == CreditNoteType.monto,
    );
    for (final creditNote in amountNotes) {
      _addCreditNote(creditNote);
    }

    notifyListeners();
  }

  void removeFromSelected(InvoiceInDb invoice) {
    _selectedInvoices.removeWhere((existing) => existing.id == invoice.id);
    _selectedDevolutions.removeWhere(
      (devolution) => devolution.originalInvoiceId == invoice.id,
    );
    _selectedCreditNotes.removeWhere(
      (creditNote) => _isLinkedCreditNote(creditNote, invoice),
    );
    if (_selectedInvoices.isEmpty) {
      _selectedCreditNotes.clear();
    }
    notifyListeners();
  }

  void clearSelected() {
    _selectedInvoices = [];
    _selectedDevolutions.clear();
    _selectedCreditNotes.clear();
    notifyListeners();
  }

  bool isInSelected(InvoiceInDb invoice) => _selectedInvoices.any((existing) => existing.id == invoice.id);
}

class PendingInvoiceMediator extends InheritedNotifier<ViewController> {
  const PendingInvoiceMediator({super.key, required super.child, required super.notifier});

  static PendingInvoiceMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PendingInvoiceMediator>()!;
  }
}
