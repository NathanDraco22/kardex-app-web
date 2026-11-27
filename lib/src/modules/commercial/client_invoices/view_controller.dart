import 'package:material_ui/material_ui.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class ClientInvoiceViewController extends ChangeNotifier {
  ClientInvoiceViewController({
    this.isWholesale = false,
    this.applyInvoiceRounding = false,
  });

  final bool isWholesale;
  final bool applyInvoiceRounding;

  DateTime? _selectedDate;

  String description = '';

  List<CommercialProductResult> items = [];

  ClientInDb? _selectedClient;

  ClientInDb? get selectedClient => _selectedClient;

  bool updatePricesOnClientChange = true;
  VoidCallback? onPricesChanged;

  set selectedClient(ClientInDb? value) {
    final canCredit = AccessManager().hasCurrentCapability(
      RoleCapability.allowCreditInvoicing,
    );
    final hasCredit = (value?.isCreditActive ?? false) && canCredit;
    final initValue = hasCredit ? PaymentType.credit : PaymentType.cash;
    selectedPaymentType = initValue;
    _selectedClient = value;
    if (value != null && updatePricesOnClientChange) {
      final level = value.defaultPriceLevel;
      items = items.map((item) {
        final priceMap = {
          1: item.product.saleProfile.salePrice,
          2: item.product.saleProfile.salePrice2,
          3: item.product.saleProfile.salePrice3,
          4: item.product.saleProfile.salePrice4,
        };
        final newPrice = priceMap[level] ?? item.product.saleProfile.salePrice;
        return item.copyWith(
          newPrice: newPrice,
          selectedPriceLevel: level,
        );
      }).toList();
      if (items.isNotEmpty) {
        onPricesChanged?.call();
      }
    }
    notifyListeners();
  }

  bool get hasZeroPriceItems => items.any((item) => item.newPrice <= 0);

  bool get hasItemsWithZeroBaseQuantity => items.any((item) => item.baseQuantity <= 0);

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  PaymentType selectedPaymentType = PaymentType.cash;

  int get totalItems => items.length;

  void addItem(CommercialProductResult item) {
    final existingItem = items.any((i) => i.product.id == item.product.id);
    if (existingItem) return;

    item.roundUpLineTotals = applyInvoiceRounding;
    items = [...items, item];
    notifyListeners();
  }

  void addMultipleItems(List<CommercialProductResult> newItems) {
    for (final item in newItems) {
      item.roundUpLineTotals = applyInvoiceRounding;
    }
    items = [...items, ...newItems];
    notifyListeners();
  }

  void refreshItems(List<CommercialProductResult> newItems) {
    for (final item in newItems) {
      item.roundUpLineTotals = applyInvoiceRounding;
    }
    items = newItems;
    notifyListeners();
  }

  void updateItem(CommercialProductResult oldItem, CommercialProductResult newItem) {
    final index = items.indexOf(oldItem);
    if (index == -1) return;
    newItem.roundUpLineTotals = applyInvoiceRounding;
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
    invoiceDiscountType = null;
    invoiceDiscountValue = 0;
    selectedClient = null;
    selectedPaymentType = PaymentType.cash;
    notifyListeners();
  }

  DiscountType? invoiceDiscountType;
  int invoiceDiscountValue = 0;

  int get itemsSubTotal => items.fold<int>(0, (sum, e) => sum + e.subTotal);

  int get itemDiscounts => items.fold<int>(0, (sum, e) => sum + e.totalDiscount);

  int get itemsNetTotal => items.fold<int>(0, (sum, e) => sum + e.total);

  int get invoiceDiscountAmount {
    final raw = DiscountType.calculateDiscountAmount(
      type: invoiceDiscountType,
      discountValue: invoiceDiscountValue,
      baseAmount: itemsNetTotal,
    );
    final shouldRound =
        applyInvoiceRounding && InvoiceRounding.isEnabled;
    return shouldRound ? InvoiceRounding.roundDownToWholeUnit(raw) : raw;
  }

  int get totalDiscount => itemDiscounts + invoiceDiscountAmount;

  int get totalAmount =>
      (itemsNetTotal - invoiceDiscountAmount).clamp(0, itemsNetTotal);

  void setInvoiceDiscount(DiscountType? type, int value) {
    if (type == null || value <= 0) {
      invoiceDiscountType = null;
      invoiceDiscountValue = 0;
    } else {
      invoiceDiscountType = type;
      invoiceDiscountValue = type == DiscountType.percentage
          ? value.clamp(0, 100)
          : value.clamp(0, itemsNetTotal);
    }
    notifyListeners();
  }

  void clearInvoiceDiscount() {
    if (invoiceDiscountType == null && invoiceDiscountValue == 0) return;
    invoiceDiscountType = null;
    invoiceDiscountValue = 0;
    notifyListeners();
  }

  List<SaleItem> createSaleItemFromCommercial() {
    final saleItems = items.map((commercial) {
      final product = commercial.product;
      return SaleItem(
        product: ProductItem.fromJson({
          ...product.toJson(),
          'unitName': commercial.selectedUnitName.isNotEmpty ? commercial.selectedUnitName : product.unitName,
        }),
        selectedPrice: commercial.selectedPriceLevel,
        cost: product.account.averageCost,
        price: commercial.newPrice,
        quantity: commercial.baseQuantity,
        discountType: commercial.effectiveDiscountType,
        discountPercentage: commercial.discountPercent,
        totalDiscount: commercial.totalDiscount,
        subTotal: commercial.subTotal,
        total: commercial.total,
        conversionFactor: commercial.conversionFactor,
        priceUnitFactor: product.priceUnitFactor,
        selectedUnitName: commercial.selectedUnitName.isNotEmpty ? commercial.selectedUnitName : product.unitName,
        standardUnitName: product.defaultUnitName,
        standardUnitFactor: product.defaultUnitFactor,
      );
    }).toList();

    return saleItems;
  }

  CreateInvoice? generateCreateInvoice(BuildContext context) {
    final saleItems = createSaleItemFromCommercial();
    final currentClient = selectedClient;

    if (currentClient == null) return null;

    int totalCost = 0;
    int itemsNet = 0;
    int itemsDisc = 0;
    for (final item in saleItems) {
      totalCost += item.lineCost;
      itemsNet += item.total;
      itemsDisc += item.totalDiscount;
    }
    var invDisc = DiscountType.calculateDiscountAmount(
      type: invoiceDiscountType,
      discountValue: invoiceDiscountValue,
      baseAmount: itemsNet,
    );
    final shouldRound =
        applyInvoiceRounding && InvoiceRounding.isEnabled;
    if (shouldRound) {
      invDisc = InvoiceRounding.roundDownToWholeUnit(invDisc);
    }
    final total = (itemsNet - invDisc).clamp(0, itemsNet);

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
      discountType: invoiceDiscountType,
      discountValue: invoiceDiscountValue,
      itemDiscounts: itemsDisc,
      invoiceDiscount: invDisc,
      totalCost: totalCost,
      total: total,
      createdBy: UserInfo(
        id: currentUser.id,
        name: currentUser.username,
      ),
      shiftId: getIt.isRegistered<ShiftCubit>() ? getIt<ShiftCubit>().activeShiftId : null,
    );

    return newInvoice;
  }
}
