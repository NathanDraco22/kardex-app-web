part of '../anon_invoices_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = AnonInvoiceWebMediator.of(context);
    final controller = mediator.tableController;
    return Card(child: AnonInvoiceTable(controller: controller));
  }
}
