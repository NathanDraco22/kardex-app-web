import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';

class ReceiptTotal {
  ReceiptTotal({
    this.paymentMethod,
    required this.total,
    this.count = 0,
  });

  PaymentMethod? paymentMethod;
  int total;
  int count;

  factory ReceiptTotal.fromJson(Map<String, dynamic> map) {
    return ReceiptTotal(
      paymentMethod: map['paymentMethod'] != null 
          ? PaymentMethod.values.byName(map['paymentMethod']) 
          : null,
      total: map['total'] ?? 0,
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      'total': total,
      'count': count,
    };
  }
}
