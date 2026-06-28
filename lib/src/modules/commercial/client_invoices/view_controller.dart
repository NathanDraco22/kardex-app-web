import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class ClientInvoiceViewController extends ChangeNotifier {
  DateTime? _selectedDate;

  String description = '';

  List<CommercialProductResult> items = [];

  ClientInDb? _selectedClient;

  ClientInDb? get selectedClient => _selectedClient;

  set selectedClient(ClientInDb? value) {
    final hasCredit = value?.isCreditActive ?? false;
    final initValue = hasCredit ? PaymentType.credit : PaymentType.cash;
    selectedPaymentType = initValue;
    _selectedClient = value;
    notifyListeners();
  }

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  PaymentType selectedPaymentType = PaymentType.cash;

  int get totalItems => items.length;

  int get totalAmount => items.fold(0, (previousValue, element) => previousValue + element.total);

  void addItem(CommercialProductResult item) {
    final existingItem = items.any((i) => i.product.id == item.product.id);
    if (existingItem) return;

    items = [...items, item];
    notifyListeners();
  }

  void addMultipleItems(List<CommercialProductResult> newItems) {
    items = [...items, ...newItems];
    notifyListeners();
  }

  void refreshItems(List<CommercialProductResult> newItems) {
    items = newItems;
    notifyListeners();
  }

  void updateItem(CommercialProductResult oldItem, CommercialProductResult newItem) {
    final index = items.indexOf(oldItem);
    items[index] = newItem;
    notifyListeners();
  }

  void removeItem(CommercialProductResult item) {
    items.remove(item);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void clear() {
    description = '';
    items = [];
    selectedClient = null;
    selectedPaymentType = PaymentType.cash;
    notifyListeners();
  }

  List<SaleItem> createSaleItemFromCommercial() {
    final saleItems = items.map((commercial) {
      final product = commercial.product;
      return SaleItem(
        product: ProductItem.fromJson(product.toJson()),
        selectedPrice: commercial.selectedPriceLevel,
        cost: product.account.averageCost,
        price: commercial.newPrice,
        quantity: commercial.quantity,
        discountPercentage: commercial.discountPercent,
        totalDiscount: commercial.totalDiscount,
        subTotal: commercial.subTotal,
        total: commercial.total,
      );
    }).toList();

    return saleItems;
  }

  CreateInvoice? generateCreateInvoice(BuildContext context) {
    final saleItems = createSaleItemFromCommercial();
    final currentClient = selectedClient;

    if (currentClient == null) return null;

    int totalCost = 0;
    int total = 0;
    for (final item in saleItems) {
      totalCost += item.cost * (item.quantity + item.bonQuantity);
      total += item.total;
    }

    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) throw Exception("User or branch not found");
    final currentUser = authState.session.user;
    final currentBranch = authState.branch;

    final newInvoice = CreateInvoice(
      branchId: currentBranch.id,
      clientId: currentClient.id,
      clientInfo: ClientInfo(
        name: currentClient.name,
        group: currentClient.group,
        address: currentClient.address,
        cardId: currentClient.cardId,
        location: currentClient.location,
        phone: currentClient.phone,
        email: currentClient.email,
      ),
      description: description,
      docNumber: "",
      saleItems: saleItems,
      status: InvoiceStatus.open,
      paymentType: selectedPaymentType,
      bankReference: "",
      totalCost: totalCost,
      total: total,
      createdBy: UserInfo(
        id: currentUser.id,
        name: currentUser.username,
      ),
    );

    return newInvoice;
  }
}
