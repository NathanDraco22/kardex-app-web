import 'package:kardex_business/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_business/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_business/src/tools/number_formatter.dart';

/// Resumen de las líneas de un producto dentro de una factura.
class ProductInvoiceLine {
  final SaleItem? item;
  final int quantity;
  final int bonQuantity;
  final int total;

  const ProductInvoiceLine({
    this.item,
    this.quantity = 0,
    this.bonQuantity = 0,
    this.total = 0,
  });

  bool get isEmpty => item == null;

  int get totalUnits => quantity + bonQuantity;

  /// Cantidad lista para mostrar, incluyendo bonificación cuando aplique.
  String get quantityText {
    final firstItem = item;
    if (firstItem == null) return "0";

    final isSingleLine =
        quantity == firstItem.quantity && bonQuantity == firstItem.bonQuantity;

    if (isSingleLine) {
      return firstItem.bonQuantity > 0
          ? "${firstItem.formattedDisplayQuantity} + ${firstItem.formattedDisplayBonQuantity}"
          : firstItem.formattedDisplayQuantity;
    }

    final factor = firstItem.displayUnitFactor <= 1 ? 1 : firstItem.displayUnitFactor;
    return NumberFormatter.decimalPattern((quantity + bonQuantity) / factor);
  }
}

extension InvoiceProductLineExtension on InvoiceInDb {
  /// Agrupa todas las líneas de la factura que pertenecen al producto indicado.
  ProductInvoiceLine productLine(String productId) {
    final matchingItems = saleItems
        .where((item) => item.product.id == productId)
        .toList();

    if (matchingItems.isEmpty) return const ProductInvoiceLine();

    return ProductInvoiceLine(
      item: matchingItems.first,
      quantity: matchingItems.fold(0, (sum, item) => sum + item.quantity),
      bonQuantity: matchingItems.fold(0, (sum, item) => sum + item.bonQuantity),
      total: matchingItems.fold(0, (sum, item) => sum + item.total),
    );
  }
}
