part of '../devolution_confirmation_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.invoice,
    required this.description,
  });
  final InvoiceInDb invoice;
  final String description;

  @override
  Widget build(BuildContext context) {
    final clientName = invoice.clientInfo.name;
    final invoiceDate = DateTimeTool.formatddMMyy(invoice.createdAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de Devolución', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Cliente: $clientName'),
            Text('Factura: ${invoice.docNumber}'),
            Text('Fecha de Factura: $invoiceDate'),
            Text('Descripción: $description'),
          ],
        ),
      ),
    );
  }
}
