import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';

class InvoiceDevolutionResponse {
  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;
  InvoiceDevolutionResponse({required this.invoice, required this.devolutions});

  factory InvoiceDevolutionResponse.fromJson(Map<String, dynamic> json) => InvoiceDevolutionResponse(
    invoice: InvoiceInDb.fromJson(json["invoice"]),
    devolutions: List<DevolutionInDb>.from(json["devolutions"].map((x) => DevolutionInDb.fromJson(x))),
  );
}
