import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

/// Muestra un diálogo compacto con las últimas 15 facturas de la sucursal.
Future<void> showRecentInvoicesDialog(
  BuildContext context, {
  required String branchId,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return RecentInvoicesDialog(branchId: branchId);
    },
  );
}

/// Diálogo compacto que lista hasta las últimas 15 facturas emitidas en [branchId].
class RecentInvoicesDialog extends StatefulWidget {
  const RecentInvoicesDialog({
    super.key,
    required this.branchId,
  });

  final String branchId;

  @override
  State<RecentInvoicesDialog> createState() => _RecentInvoicesDialogState();
}

class _RecentInvoicesDialogState extends State<RecentInvoicesDialog> {
  static const int _maxInvoices = 15;
  late Future<List<InvoiceInDb>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _fetchRecentInvoices();
  }

  Future<List<InvoiceInDb>> _fetchRecentInvoices() {
    final params = InvoiceQueryParams()
      ..branchId = widget.branchId
      ..offset = 0
      ..limit = _maxInvoices;
    return context.read<InvoicesRepository>().getInvoicesHistory(params);
  }

  void _reload() {
    setState(() {
      _invoicesFuture = _fetchRecentInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Últimas $_maxInvoices Facturas",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Toca una factura para ver detalles o reimprimir",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Actualizar",
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: "Cerrar",
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<InvoiceInDb>>(
                  future: _invoicesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 42, color: Colors.red.shade300),
                              const SizedBox(height: 12),
                              Text(
                                "No se pudieron cargar las facturas.\n${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _reload,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Reintentar"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final invoices = (snapshot.data ?? const <InvoiceInDb>[]).take(_maxInvoices).toList();

                    if (invoices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              "No hay facturas registradas",
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: invoices.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final invoice = invoices[index];
                        return _InvoiceRowTile(
                          invoice: invoice,
                          onTap: () => showInvoiceViewerDialog(context, invoice),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoiceRowTile extends StatelessWidget {
  const _InvoiceRowTile({
    required this.invoice,
    required this.onTap,
  });

  final InvoiceInDb invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCancelled = invoice.status == InvoiceStatus.cancelled;
    final isCredit = invoice.paymentType == PaymentType.credit;
    final dateText = DateTimeTool.formatddMMyy(invoice.createdAt);
    final timeText = DateTimeTool.formatHHmm(invoice.createdAt);
    final totalText = NumberFormatter.convertToMoneyLike(invoice.total);
    final clientName = invoice.clientInfo.name.trim().isNotEmpty
        ? invoice.clientInfo.name
        : "Consumidor Final";

    final statusColor = isCancelled
        ? AppThemeTokens.danger
        : isCredit
            ? AppThemeTokens.warning
            : AppThemeTokens.success;

    final statusLabel = isCancelled
        ? "Anulada"
        : isCredit
            ? "Crédito"
            : "Contado";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    timeText,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          invoice.docNumber,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              totalText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: isCancelled ? TextDecoration.lineThrough : null,
                color: isCancelled ? Colors.grey.shade500 : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
