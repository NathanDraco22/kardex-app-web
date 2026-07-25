part of '../client_invoices_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final controller = ClientInvoiceWebMediator.of(context).viewController;
    final writeCubit = context.read<WriteInvoiceCubit>();
    final isRestrictStock = writeCubit.documentType != CommercialDocumentType.quote;
    return Card(
      child: ClientInvoiceTable(
        controller: controller,
        restrictStock: isRestrictStock,
      ),
    );
  }
}
