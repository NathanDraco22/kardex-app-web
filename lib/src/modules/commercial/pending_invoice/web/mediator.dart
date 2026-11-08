import 'package:flutter/material.dart';
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

  void addToSelected(InvoiceInDb invoice) {
    _selectedInvoices.add(invoice);
    final devolutionsMatched = devolutions.where((devolution) => devolution.originalInvoiceId == invoice.id);
    _selectedDevolutions.addAll(devolutionsMatched);

    final creditNotesMatched = creditNotes.where(
      (cn) =>
          cn.invoiceId == invoice.id ||
          (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber),
    );
    _selectedCreditNotes.addAll(creditNotesMatched);

    // Also include unlinked amount-type credit notes for this client
    final amountNotes = creditNotes.where(
      (cn) => cn.type == CreditNoteType.monto && !_selectedCreditNotes.contains(cn),
    );
    _selectedCreditNotes.addAll(amountNotes);

    notifyListeners();
  }

  void removeFromSelected(InvoiceInDb invoice) {
    _selectedInvoices.remove(invoice);
    _selectedDevolutions.removeWhere((devolution) => devolution.originalInvoiceId == invoice.id);
    _selectedCreditNotes.removeWhere(
      (cn) =>
          cn.invoiceId == invoice.id ||
          (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber),
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

  bool isInSelected(InvoiceInDb invoice) => _selectedInvoices.contains(invoice);
}

class PendingInvoiceMediator extends InheritedNotifier<ViewController> {
  const PendingInvoiceMediator({super.key, required super.child, required super.notifier});

  static PendingInvoiceMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PendingInvoiceMediator>()!;
  }
}
