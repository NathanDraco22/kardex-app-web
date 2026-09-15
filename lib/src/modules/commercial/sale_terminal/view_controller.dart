import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/terminal_draft_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_business/kardex_business.dart';

class SaleTerminalViewController extends ChangeNotifier {
  final FocusNode searchFocusNode = FocusNode();

  /// Controla si las acciones automáticas (agregar producto, limpiar carrito, etc.)
  /// deben reenfocar el buscador. Se activa únicamente en Web / Desktop para evitar
  /// desplegar el teclado en pantalla en dispositivos móviles y tablets.
  bool autoFocusSearch = false;

  String description = '';

  String? currentDraftId;

  List<CommercialProductResult> items = [];

  ClientInDb? _selectedClient;

  ClientInDb? get selectedClient => _selectedClient;

  int _selectedPriceLevel = 1;

  int get selectedPriceLevel => _selectedPriceLevel;

  PaymentType selectedPaymentType = PaymentType.cash;

  bool _isWholesale = false;

  bool get isWholesale => _isWholesale;

  set isWholesale(bool value) {
    _isWholesale = value;
    notifyListeners();
  }

  set selectedClient(ClientInDb? value) {
    final hasCredit = value?.isCreditActive ?? false;
    selectedPaymentType = hasCredit ? PaymentType.credit : PaymentType.cash;
    _selectedClient = value;
    if (value != null) {
      selectedPriceLevel = value.defaultPriceLevel;
    }
    notifyListeners();
  }

  set selectedPriceLevel(int value) {
    _selectedPriceLevel = value;
    final priceMap = {
      1: (CommercialProductResult item) => item.product.saleProfile.salePrice,
      2: (CommercialProductResult item) => item.product.saleProfile.salePrice2,
      3: (CommercialProductResult item) => item.product.saleProfile.salePrice3,
      4: (CommercialProductResult item) => item.product.saleProfile.salePrice4,
    };
    final priceResolver = priceMap[value];
    if (priceResolver != null) {
      items = items.map((item) {
        final newPrice = priceResolver(item);
        return item.copyWith(
          newPrice: newPrice,
          selectedPriceLevel: value,
        );
      }).toList();
    }
    notifyListeners();
  }

  bool get hasZeroPriceItems => items.any((item) => item.newPrice <= 0);

  bool get hasItemsWithZeroQuantity => items.any((item) => item.quantity == 0);

  int get totalItems => items.length;

  int get totalQuantity => items.fold(0, (previousValue, element) => previousValue + element.quantity);

  int get totalAmount => items.fold(0, (previousValue, element) => previousValue + element.total);

  int get totalDiscount =>
      items.fold(0, (previousValue, element) => previousValue + element.totalDiscount);

  void addItem(CommercialProductResult item) {
    final existingIndex = items.indexWhere((i) => i.product.id == item.product.id);
    if (existingIndex != -1) {
      items[existingIndex] = item;
    } else {
      items = [...items, item];
    }
    notifyListeners();
  }

  void quickAddItem(CommercialProductResult item) {
    final existingIndex = items.indexWhere((i) => i.product.id == item.product.id);
    if (existingIndex != -1) {
      final existing = items[existingIndex];
      final maxQuantity = existing.product.account.availableStock ~/ existing.conversionFactor;
      if (existing.quantity < maxQuantity) {
        existing.quantity += 1;
        notifyListeners();
      }
      return;
    }
    items = [...items, item];
    notifyListeners();
  }

  bool quickAddProduct(BuildContext context, ProductInDbInBranch product) {
    final result = CommercialProductResult(
      product: product,
      defaultPriceLevel: selectedPriceLevel,
      preferredUnitType: isWholesale ? 'max' : 'min',
    );
    result.quantity = 1;

    final existingIndex = items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex != -1) {
      final existing = items[existingIndex];
      final maxQuantity = existing.product.account.availableStock ~/ existing.conversionFactor;
      if (existing.quantity >= maxQuantity) {
        DialogManager.showInfoDialog(context, "No hay más stock disponible para este producto");
        requestSearchFocus();
        return false;
      }
    } else {
      if (product.account.availableStock < (result.quantity * result.conversionFactor)) {
        DialogManager.showInfoDialog(context, "No hay stock disponible para este producto");
        requestSearchFocus();
        return false;
      }
    }

    quickAddItem(result);
    requestSearchFocus();
    return true;
  }

  void updateItem(CommercialProductResult oldItem, CommercialProductResult newItem) {
    final index = items.indexOf(oldItem);
    if (index == -1) return;
    items[index] = newItem;
    notifyListeners();
  }

  void removeItem(CommercialProductResult item) {
    items.remove(item);
    notifyListeners();
  }

  void refresh() => notifyListeners();

  void requestSearchFocus({bool force = false}) {
    if (!force && !autoFocusSearch) return;
    if (searchFocusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!searchFocusNode.hasFocus && searchFocusNode.canRequestFocus) {
        searchFocusNode.requestFocus();
      }
    });
  }

  void clear() {
    description = '';
    currentDraftId = null;
    items = [];
    _selectedClient = null;
    _selectedPriceLevel = 1;
    selectedPaymentType = PaymentType.cash;
    notifyListeners();
    requestSearchFocus();
  }

  CreateHoldSale exportToDraft({
    required String branchId,
    UserInfo? createdBy,
  }) {
    return CreateHoldSale(
      branchId: branchId,
      client: selectedClient,
      selectedPriceLevel: selectedPriceLevel,
      isWholesale: isWholesale,
      description: description,
      selectedPaymentType: selectedPaymentType,
      items: items.map((i) => i.toHoldSaleItem()).toList(),
      totalQuantity: totalQuantity,
      totalAmount: totalAmount,
      createdBy: createdBy,
    );
  }

  void loadFromDraft(HoldSaleInDb draft) {
    currentDraftId = draft.id;
    _selectedClient = draft.client;
    _selectedPriceLevel = draft.selectedPriceLevel;
    _isWholesale = draft.isWholesale;
    description = draft.description;
    selectedPaymentType = draft.selectedPaymentType;
    items = draft.items.map((i) => i.toCommercialProductResult()).toList();
    notifyListeners();
    requestSearchFocus();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  List<SaleItem> createSaleItemFromCommercial() {
    final saleItems = items.map((commercial) {
      final product = commercial.product;
      return SaleItem(
        product: ProductItem.fromJson({
          ...product.toJson(),
          'unitName': commercial.selectedUnitName.isNotEmpty
              ? commercial.selectedUnitName
              : product.unitName,
        }),
        selectedPrice: commercial.selectedPriceLevel,
        cost: product.account.averageCost,
        price: commercial.newPrice,
        quantity: commercial.quantity * commercial.conversionFactor,
        discountPercentage: commercial.discountPercent,
        totalDiscount: commercial.totalDiscount,
        subTotal: commercial.subTotal,
        total: commercial.total,
        conversionFactor: commercial.conversionFactor,
      );
    }).toList();

    return saleItems;
  }

  CreateInvoice? generateCreateInvoice() {
    final saleItems = createSaleItemFromCommercial();
    if (saleItems.isEmpty) return null;

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

    final currentClient = selectedClient;
    final String clientId;
    final ClientInfo clientInfo;
    if (currentClient == null) {
      clientId = kSaleClientId;
      clientInfo = ClientInfo(name: "Sin Cliente", group: "");
    } else {
      clientId = currentClient.id;
      clientInfo = ClientInfo(
        name: currentClient.name,
        group: currentClient.group,
        address: currentClient.address,
        cardId: currentClient.cardId,
        location: currentClient.location,
        phone: currentClient.phone,
        email: currentClient.email,
      );
    }

    return CreateInvoice(
      branchId: currentBranch.id,
      clientId: clientId,
      clientInfo: clientInfo,
      docNumber: "",
      description: description,
      saleItems: saleItems,
      status: InvoiceStatus.open,
      paymentType: selectedPaymentType,
      bankReference: "",
      amountPaid: 0,
      totalCost: totalCost,
      total: total,
      createdBy: UserInfo(
        id: currentUser.id,
        name: currentUser.username,
      ),
    );
  }
}
