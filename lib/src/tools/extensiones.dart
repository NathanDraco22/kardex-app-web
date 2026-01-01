import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/product_transaction/product_transaction.dart';
import 'tools.dart';

extension BuildContextExtension on BuildContext {
  bool isMobile() => MediaQuery.sizeOf(this).width < maxPhoneScreenWidth;
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
