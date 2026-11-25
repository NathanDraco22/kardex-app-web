part of '../devolutions_selection_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.invoice,
    required this.devolutions,
  });

  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;

  @override
  Widget build(BuildContext context) {
    final authState = getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>().state : null;
    final branch = authState is Authenticated ? authState.branch : null;

    final targetDevolutions =
        devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
    final returnedTotal = targetDevolutions.fold<int>(0, (sum, d) => sum + d.total);

    final paymentLabel = <PaymentType>[.card, .transfer].contains(invoice.paymentType) &&
            invoice.bankReference.isNotEmpty
        ? "${invoice.paymentType.typeLabel} - Ref: ${invoice.bankReference}"
        : invoice.paymentType.typeLabel;

    final clientLabel = invoice.clientId == kSaleClientId
        ? invoice.clientInfo.name
        : "${invoice.clientId} - ${invoice.clientInfo.name}";

    final (statusText, statusColor) = _statusInfo(invoice.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Factura No. ${invoice.docNumber}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          paymentLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateTimeTool.formatddMMyy(invoice.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      DateTimeTool.formatHHmm(invoice.createdAt),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 1),
            Wrap(
              spacing: 20,
              runSpacing: 6,
              children: [
                if (branch != null)
                  _InfoItem(icon: Icons.storefront_outlined, label: "Sucursal", value: branch.name),
                _InfoItem(icon: Icons.person_outline, label: "Cliente", value: clientLabel),
                _InfoItem(
                  icon: Icons.badge_outlined,
                  label: "Vendedor",
                  value: invoice.createdBy.name,
                ),
                if (invoice.clientInfo.location != null &&
                    invoice.clientInfo.location!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.location_on_outlined,
                    label: "Ubicación",
                    value: invoice.clientInfo.location!,
                  ),
                if (invoice.clientInfo.address != null &&
                    invoice.clientInfo.address!.isNotEmpty)
                  _InfoItem(
                    icon: Icons.home_outlined,
                    label: "Dirección",
                    value: invoice.clientInfo.address!,
                  ),
                if (invoice.orderInfo != null)
                  _InfoItem(
                    icon: Icons.assignment_outlined,
                    label: "Pedido",
                    value:
                        "No. ${invoice.orderInfo!.docNumber} (${invoice.orderInfo!.createdBy.name})",
                  ),
              ],
            ),
            if (invoice.description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Observación: ${invoice.description}",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  _TotalMetric(
                    label: "Subtotal",
                    value: NumberFormatter.convertToMoneyLike(invoice.itemsSubTotal),
                  ),
                  if (invoice.totalDiscount > 0)
                    _TotalMetric(
                      label: "Descuento",
                      value: "-${NumberFormatter.convertToMoneyLike(invoice.totalDiscount)}",
                      valueColor: Colors.orange.shade800,
                    ),
                  _TotalMetric(
                    label: "Total Factura",
                    value: NumberFormatter.convertToMoneyLike(invoice.total),
                    isBold: true,
                  ),
                  _TotalMetric(
                    label: "Pagado",
                    value: NumberFormatter.convertToMoneyLike(invoice.amountPaid),
                    valueColor: Colors.green.shade800,
                  ),
                ],
              ),
            ),
            if (targetDevolutions.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Esta factura ya tiene ${targetDevolutions.length} "
                        "${targetDevolutions.length == 1 ? 'devolución previa' : 'devoluciones previas'} "
                        "por ${NumberFormatter.convertToMoneyLike(returnedTotal)}.",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  (String, Color) _statusInfo(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return ("Pagada", Colors.green.shade700);
      case InvoiceStatus.partiallypaid:
        return ("Parcial", Colors.orange.shade700);
      case InvoiceStatus.open:
        return ("Sin pagar", Colors.red.shade700);
      case InvoiceStatus.draft:
        return ("Borrador", Colors.grey.shade700);
      case InvoiceStatus.cancelled:
        return ("Cancelada", Colors.red.shade900);
    }
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _TotalMetric extends StatelessWidget {
  const _TotalMetric({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
