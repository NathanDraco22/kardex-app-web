import 'package:material_ui/material_ui.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';

class AnonInvoiceViewController extends ChangeNotifier {
  DateTime? _selectedDate;
  String description = '';
  List<CommercialProductResult> items = [];

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  int get totalItems => items.length;

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
    return InvoiceRounding.isEnabled
        ? InvoiceRounding.roundDownToWholeUnit(raw)
        : raw;
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

  void addItem(CommercialProductResult item) {
    final existingItem = items.any((i) => i.product.id == item.product.id);
    if (existingItem) return;

    item.roundUpLineTotals = true;
    items = [...items, item];
    notifyListeners();
  }

  void addItemIfNotExists(CommercialProductResult item) => addItem(item);

  void updateItem(CommercialProductResult oldItem, CommercialProductResult newItem) {
    final index = items.indexOf(oldItem);
    if (index != -1) {
      newItem.roundUpLineTotals = true;
      items[index] = newItem;
      notifyListeners();
    }
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
    _selectedDate = null;
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
}
