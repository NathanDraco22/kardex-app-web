import 'package:kardex_business/kardex_business.dart';

/// Valida si una factura es elegible para crear una devolución directa.
///
/// Retorna `null` si es elegible, o un mensaje descriptivo si está bloqueada:
/// - Facturas canceladas o con descuento global no admiten devoluciones por ítem.
/// - Facturas de contado (`cash`, `transfer`, `card`, `other`, `check`) siempre se permiten.
/// - Facturas a crédito solo se permiten si no tienen abonos (`amountPaid == 0` y `status == open`).
String? validateInvoiceForDevolution(InvoiceInDb invoice) {
  if (invoice.status == InvoiceStatus.cancelled) {
    return "No se pueden realizar devoluciones sobre facturas canceladas.";
  }
  if (invoice.invoiceDiscount > 0) {
    return "No se permiten devoluciones por producto en facturas con descuento global.";
  }
  if (invoice.paymentType == PaymentType.credit &&
      (invoice.amountPaid > 0 ||
          invoice.status == InvoiceStatus.partiallypaid ||
          invoice.status == InvoiceStatus.paid)) {
    return "No se permiten devoluciones sobre facturas a crédito con abonos o pagadas.";
  }
  return null;
}

/// Calcula las cantidades base ya devueltas por índice de línea de factura,
/// sumando devoluciones activas (`status != cancelled`) y notas de crédito
/// activas (`status != cancelled && status != rejected`).
Map<int, int> computePreviouslyReturnedByLine({
  required List<SaleItem> saleItems,
  required List<DevolutionInDb> devolutions,
  List<CreditNoteInDb> creditNotes = const [],
}) {
  final returnedByIndex = <int, int>{};
  final legacyItems = <SaleItem>[];

  for (final dev in devolutions) {
    if (dev.status == DevolutionStatus.cancelled) continue;
    for (final item in dev.returnedItems) {
      final index = item.invoiceItemIndex;
      if (index != null &&
          index >= 0 &&
          index < saleItems.length &&
          saleItems[index].product.id == item.product.id) {
        returnedByIndex[index] =
            (returnedByIndex[index] ?? 0) + item.quantity.abs();
      } else {
        legacyItems.add(item);
      }
    }
  }

  for (final note in creditNotes) {
    if (note.status == CreditNoteStatus.cancelled ||
        note.status == CreditNoteStatus.rejected) {
      continue;
    }
    for (final item in note.returnedItems) {
      final index = item.invoiceItemIndex;
      if (index != null &&
          index >= 0 &&
          index < saleItems.length &&
          saleItems[index].product.id == item.product.id) {
        returnedByIndex[index] =
            (returnedByIndex[index] ?? 0) + item.quantity.abs();
      } else {
        legacyItems.add(item);
      }
    }
  }

  for (final item in legacyItems) {
    var qtyLeft = item.quantity.abs();
    if (qtyLeft <= 0) continue;

    final itemFactor = UnitConversionTool.ensureSafeFactor(item.conversionFactor);
    final exactMatches = <int>[];
    final fallbackMatches = <int>[];

    for (var i = 0; i < saleItems.length; i++) {
      final line = saleItems[i];
      if (line.product.id != item.product.id) continue;
      final lineFactor =
          UnitConversionTool.ensureSafeFactor(line.conversionFactor);
      if (lineFactor == itemFactor) {
        exactMatches.add(i);
      } else {
        fallbackMatches.add(i);
      }
    }

    final orderedMatches = [...exactMatches, ...fallbackMatches];
    if (orderedMatches.isEmpty) continue;

    for (final i in orderedMatches) {
      if (qtyLeft <= 0) break;
      final already = returnedByIndex[i] ?? 0;
      final capacity = (saleItems[i].quantity - already).clamp(0, saleItems[i].quantity);
      final take = qtyLeft < capacity ? qtyLeft : capacity;
      if (take > 0) {
        returnedByIndex[i] = already + take;
        qtyLeft -= take;
      }
    }

    if (qtyLeft > 0) {
      final firstIndex = orderedMatches.first;
      returnedByIndex[firstIndex] = (returnedByIndex[firstIndex] ?? 0) + qtyLeft;
    }
  }

  return returnedByIndex;
}
