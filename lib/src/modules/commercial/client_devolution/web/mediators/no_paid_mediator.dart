import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';

class NoPaidViewController extends ChangeNotifier {
  List<InvoiceInDb> _selectedInvoices = [];
  ClientInDb? _selectedClient;

  List<InvoiceInDb> get selectedInvoices => _selectedInvoices;
  ClientInDb? get selectedClient => _selectedClient;

  void changeClient(ClientInDb newClient) {
    _selectedClient = newClient;
    _selectedInvoices = [];
    notifyListeners();
  }

  void addToSelected(InvoiceInDb invoice) {
    _selectedInvoices.add(invoice);
    notifyListeners();
  }

  void removeFromSelected(InvoiceInDb invoice) {
    _selectedInvoices.remove(invoice);
    notifyListeners();
  }

  void clearSelected() {
    _selectedInvoices = [];
    notifyListeners();
  }

  bool isInSelected(InvoiceInDb invoice) => _selectedInvoices.contains(invoice);
}

class NoPaidInvoiceMediator extends InheritedNotifier<NoPaidViewController> {
  const NoPaidInvoiceMediator({super.key, required super.child, required super.notifier});

  static NoPaidInvoiceMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NoPaidInvoiceMediator>()!;
  }
}
