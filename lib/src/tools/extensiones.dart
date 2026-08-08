import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

extension BuildContextExtension on BuildContext {
  /// Retorna true si el ancho de pantalla es de un dispositivo móvil (< 600 dp)
  bool isMobile() => MediaQuery.sizeOf(this).width < maxPhoneScreenWidth;

  /// Retorna true si el ancho de pantalla corresponde a una tablet en portrait (>= 600 dp y < 840 dp)
  bool isTablet() {
    final width = MediaQuery.sizeOf(this).width;
    return width >= maxPhoneScreenWidth && width < maxTabletScreenWidth;
  }

  /// Retorna true si el ancho de pantalla es de escritorio o tablet en landscape (>= 840 dp)
  bool isDesktop() => MediaQuery.sizeOf(this).width >= maxTabletScreenWidth;

  /// Retorna true si la pantalla es móvil o tablet (< 840 dp)
  bool isMobileOrTablet() => MediaQuery.sizeOf(this).width < maxTabletScreenWidth;

  /// Retorna true si la pantalla es tablet o escritorio (>= 600 dp)
  bool isTabletOrDesktop() => MediaQuery.sizeOf(this).width >= maxPhoneScreenWidth;
}


extension TransactionSubTypeExtension on TransactionSubType {
  String get value {
    switch (this) {
      case TransactionSubType.entry:
        return 'Entrada';
      case TransactionSubType.exit:
        return 'Salida';
      case TransactionSubType.invoice:
        return 'Factura';
      case TransactionSubType.devolution:
        return 'Devolución';
      case TransactionSubType.transfer:
        return 'Transferencia';
      case TransactionSubType.adjustment:
        return 'Ajuste';
      case TransactionSubType.loss:
        return 'Pérdida';
    }
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
