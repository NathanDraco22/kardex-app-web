import '../domain/models/common/discount_type.dart';
import '../domain/models/common/sale_item_model.dart';
import 'unit_conversion_tool.dart';

/// Reglas de redondeo hacia arriba de importes de factura.
///
/// Con la opción activa:
/// - el subtotal de cada línea se redondea hacia arriba al siguiente entero
///   de la moneda;
/// - los descuentos se redondean hacia abajo para que la resta
///   `subtotal - descuentos = total` se mantenga exacta;
/// - el total de la factura queda en un número entero.
///
/// La activación se resuelve con un resolver configurado por `AppSettingsCubit`
/// para no acoplar los modelos de dominio al cubit.
class InvoiceRounding {
  InvoiceRounding._();

  static bool Function()? _enabledResolver;

  static void configureEnabledResolver(bool Function()? resolver) {
    _enabledResolver = resolver;
  }

  static bool get isEnabled => _enabledResolver?.call() ?? false;

  static int roundUpToWholeUnit(int cents) {
    if (cents <= 0) return 0;
    return ((cents + 99) ~/ 100) * 100;
  }

  static int roundDownToWholeUnit(int cents) {
    if (cents <= 0) return 0;
    return (cents ~/ 100) * 100;
  }

  static int _rawSubTotal(SaleItem item) {
    if (item.price > 0 && item.quantity > 0) {
      return UnitConversionTool.calculateLineTotal(
        item.price,
        item.quantity,
        priceUnitFactor: item.priceUnitFactor,
      );
    }
    return item.subTotal < 0 ? 0 : item.subTotal;
  }

  static int rawItemDiscount(SaleItem item, int subTotal) {
    if (item.discountType == DiscountType.percentage) {
      final pct = item.discountPercentage.clamp(0, 100);
      return ((subTotal * pct) / 100).round();
    }
    if (item.discountType == DiscountType.amount) {
      return item.totalDiscount.clamp(0, subTotal);
    }
    if (item.discountPercentage > 0) {
      final pct = item.discountPercentage.clamp(0, 100);
      return ((subTotal * pct) / 100).round();
    }
    if (item.totalDiscount > 0) {
      return item.totalDiscount.clamp(0, subTotal);
    }
    return 0;
  }

  /// Total proyectado de la factura que se generaría con [items].
  ///
  /// Se usa para conversiones de órdenes/cotizaciones, donde todavía no existe
  /// la factura pero el diálogo de pago necesita el importe redondeado.
  static int calculateInvoiceTotal({
    required List<SaleItem> items,
    DiscountType? discountType,
    int discountValue = 0,
  }) {
    if (!isEnabled) {
      final itemsNet = items.fold<int>(0, (sum, item) => sum + item.total);
      final invoiceDiscount = DiscountType.calculateDiscountAmount(
        type: discountType,
        discountValue: discountValue,
        baseAmount: itemsNet,
      );
      return (itemsNet - invoiceDiscount).clamp(0, itemsNet);
    }

    var itemsNet = 0;
    for (final item in items) {
      final subTotal = roundUpToWholeUnit(_rawSubTotal(item));
      final discount = roundDownToWholeUnit(rawItemDiscount(item, subTotal));
      itemsNet += subTotal - discount;
    }

    final invoiceDiscount = roundDownToWholeUnit(
      DiscountType.calculateDiscountAmount(
        type: discountType,
        discountValue: discountValue,
        baseAmount: itemsNet,
      ),
    );
    return (itemsNet - invoiceDiscount).clamp(0, itemsNet);
  }

  /// Igual que [calculateInvoiceTotal], pero conserva [fallbackTotal] cuando la
  /// opción está apagada. Útil para órdenes/cotizaciones que ya tienen un total
  /// calculado por el backend.
  static int projectedInvoiceTotal({
    required int fallbackTotal,
    required List<SaleItem> items,
    DiscountType? discountType,
    int discountValue = 0,
  }) {
    if (!isEnabled) return fallbackTotal;
    return calculateInvoiceTotal(
      items: items,
      discountType: discountType,
      discountValue: discountValue,
    );
  }
}
