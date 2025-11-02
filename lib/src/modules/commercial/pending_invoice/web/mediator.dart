import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';

class ViewController extends ChangeNotifier {
  List<InvoiceInDb> _selectedInvoices = [];
  final List<DevolutionInDb> _selectedDevolutions = [];

  ClientInDb? _selectedClient;

  List<DevolutionInDb> devolutions = [];

  List<InvoiceInDb> get selectedInvoices => _selectedInvoices;
  ClientInDb? get selectedClient => _selectedClient;
  List<DevolutionInDb> get selectedDevolutions => _selectedDevolutions;

  void changeClient(ClientInDb newClient) {
    _selectedClient = newClient;
    _selectedInvoices = [];
    notifyListeners();
  }

  void addToSelected(InvoiceInDb invoice) {
    _selectedInvoices.add(invoice);
    final devolutionsMatched = devolutions.where((devolution) => devolution.originalInvoiceId == invoice.id);

    _selectedDevolutions.addAll(devolutionsMatched);

    notifyListeners();
  }

  void removeFromSelected(InvoiceInDb invoice) {
    _selectedInvoices.remove(invoice);
    _selectedDevolutions.removeWhere((devolution) => devolution.originalInvoiceId == invoice.id);
    notifyListeners();
  }

  void clearSelected() {
    _selectedInvoices = [];
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
