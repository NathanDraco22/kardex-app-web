part of '../client_invoices_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final controller = ClientInvoiceWebMediator.of(context).tableController;
    final writeCubit = context.read<WriteInvoiceCubit>();
    final isRestrictQuantity = writeCubit.documentType != CommercialDocumentType.quote;
    return Card(
      child: ClientInvoiceTable(
        controller: controller,
        restrictQuantity: isRestrictQuantity,
      ),
    );
  }
}
