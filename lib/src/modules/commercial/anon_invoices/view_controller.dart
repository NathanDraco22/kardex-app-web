import 'package:flutter/material.dart';
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

  int get totalAmount => items.fold<int>(0, (previousValue, element) => previousValue + element.total);

  void addItem(CommercialProductResult item) {
    final existingItem = items.any((i) => i.product.id == item.product.id);
    if (existingItem) return;

    items = [...items, item];
    notifyListeners();
  }

  void addItemIfNotExists(CommercialProductResult item) => addItem(item);

  void updateItem(CommercialProductResult oldItem, CommercialProductResult newItem) {
    final index = items.indexOf(oldItem);
    if (index != -1) {
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
    _selectedDate = null;
    notifyListeners();
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
}
