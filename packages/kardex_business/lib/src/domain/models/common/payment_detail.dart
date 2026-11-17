import 'package:kardex_business/src/domain/models/app_setting/app_currency.dart';
import 'package:kardex_business/src/tools/number_formatter.dart';

/// Detalle opcional del pago recibido en una factura o recibo.
///
/// Registra la moneda en la que pagó el cliente, el monto entregado en
/// centavos de esa moneda, la tasa de cambio congelada al momento del cobro
/// y el vuelto entregado en centavos de la moneda primaria.
class PaymentDetail {
  final AppCurrency paidCurrency;
  final int tenderedAmount;
  final double exchangeRate;
  final int changeAmount;

  const PaymentDetail({
    required this.paidCurrency,
    required this.tenderedAmount,
    required this.exchangeRate,
    this.changeAmount = 0,
  });

  bool isSecondaryPayment(AppCurrency primaryCurrency) =>
      paidCurrency != primaryCurrency;

  String formatTenderedLabel(AppCurrency primaryCurrency) {
    final tendered = NumberFormatter.formatMoney(tenderedAmount, paidCurrency);
    if (isSecondaryPayment(primaryCurrency)) {
      return '$tendered (T.C. ${exchangeRate.toStringAsFixed(2)})';
    }
    return tendered;
  }

  String formatChangeLabel(AppCurrency primaryCurrency) =>
      NumberFormatter.formatMoney(changeAmount, primaryCurrency);

  factory PaymentDetail.fromJson(Map<String, dynamic> json) => PaymentDetail(
        paidCurrency: AppCurrency.fromCode(json['paidCurrency'] as String?),
        tenderedAmount: (json['tenderedAmount'] as num?)?.toInt() ?? 0,
        exchangeRate: (json['exchangeRate'] as num?)?.toDouble() ?? 1.0,
        changeAmount: (json['changeAmount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'paidCurrency': paidCurrency.code,
        'tenderedAmount': tenderedAmount,
        'exchangeRate': exchangeRate,
        'changeAmount': changeAmount,
      };
}
