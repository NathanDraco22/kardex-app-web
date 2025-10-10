import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';

class OrderToInvoiceResponse {
  final OrderInDb order;
  final InvoiceInDb invoice;

  OrderToInvoiceResponse({
    required this.order,
    required this.invoice,
  });

  factory OrderToInvoiceResponse.fromJson(Map<String, dynamic> json) => OrderToInvoiceResponse(
    order: OrderInDb.fromJson(json['order']),
    invoice: InvoiceInDb.fromJson(json['invoice']),
  );
}
