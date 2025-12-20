import 'package:kardex_app_front/src/domain/models/invoice/invoice_totals.dart';

class AdminChartsResponses {
  final List<InvoiceTotals> last7DaysTotals;

  AdminChartsResponses({
    required this.last7DaysTotals,
  });

  factory AdminChartsResponses.fromJson(Map<String, dynamic> json) => AdminChartsResponses(
    last7DaysTotals: List<InvoiceTotals>.from(
      json["last7DaysTotals"].map((x) => InvoiceTotals.fromJson(x)),
    ),
  );
}
