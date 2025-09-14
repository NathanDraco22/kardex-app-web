part of '../client_invoices_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final controller = ClientInvoiceWebMediator.of(context).tableController;
    return Card(
      child: ClientInvoiceTable(
        controller: controller,
      ),
    );
  }
}
