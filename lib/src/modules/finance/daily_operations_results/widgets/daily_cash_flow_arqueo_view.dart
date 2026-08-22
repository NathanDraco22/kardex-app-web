import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/widgets/custom_invoice_list_tile.dart';
import 'package:kardex_app_front/widgets/custom_receipt_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/inspectors/invoice_inspector.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_business/kardex_business.dart';

class DailyCashFlowArqueoView extends StatefulWidget {
  final TotalsResult result;

  const DailyCashFlowArqueoView({super.key, required this.result});

  @override
  State<DailyCashFlowArqueoView> createState() => _DailyCashFlowArqueoViewState();
}

class _DailyCashFlowArqueoViewState extends State<DailyCashFlowArqueoView> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final validInvoices = widget.result.detailInvoices
        .where((e) => e.paymentType != PaymentType.credit)
        .toList();
    final validReceipts = widget.result.detailReceipts;

    final invoicesTotal = validInvoices.fold<int>(0, (prev, e) => prev + e.total);
    final receiptsTotal = validReceipts.fold<int>(0, (prev, e) => prev + e.total);
    final grandTotal = invoicesTotal + receiptsTotal;

    final isWide = context.isTabletOrDesktop();

    return Column(
      children: [
        _TotalsHeader(
          invoicesTotal: invoicesTotal,
          receiptsTotal: receiptsTotal,
          grandTotal: grandTotal,
        ),
        if (!isWide) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  label: Text("Recibos (${validReceipts.length})"),
                  icon: const Icon(Icons.receipt_long, size: 18),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text("Facturas (${validInvoices.length})"),
                  icon: const Icon(Icons.point_of_sale, size: 18),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _tabIndex = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: _tabIndex == 0
                  ? _ReceiptsTable(receipts: validReceipts)
                  : _InvoicesTable(invoices: validInvoices),
            ),
          ),
        ] else ...[
          // En Tablet y Desktop mostramos ambos paneles en paralelo para arqueo inmediato
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, color: Colors.green.shade700, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  "Recibos / Abonos (${validReceipts.length})",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _ReceiptsTable(receipts: validReceipts),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.point_of_sale, color: Colors.blue.shade700, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  "Facturas de Contado (${validInvoices.length})",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _InvoicesTable(invoices: validInvoices),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TotalsHeader extends StatelessWidget {
  final int invoicesTotal;
  final int receiptsTotal;
  final int grandTotal;

  const _TotalsHeader({
    required this.invoicesTotal,
    required this.receiptsTotal,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TitleLabel(
              title: "Recibos",
              bigTitle: NumberFormatter.convertToMoneyLike(receiptsTotal),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(height: 36, child: VerticalDivider()),
            TitleLabel(
              title: "Facturas Contado",
              bigTitle: NumberFormatter.convertToMoneyLike(invoicesTotal),
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const SizedBox(height: 36, child: VerticalDivider()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: Colors.green.shade800),
                child: TitleLabel(
                  title: "Ingreso Total de Caja",
                  bigTitle: NumberFormatter.convertToMoneyLike(grandTotal),
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptsTable extends StatelessWidget {
  final List<ReceiptInDb> receipts;

  const _ReceiptsTable({required this.receipts});

  @override
  Widget build(BuildContext context) {
    if (receipts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No hay recibos registrados en este día", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: receipts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = receipts[index];
        return CustomReceiptListTile(
          receipt: item,
          onTap: () {
            showReceiptViewerDialog(context, item);
          },
        );
      },
    );
  }
}

class _InvoicesTable extends StatelessWidget {
  final List<InvoiceInDb> invoices;

  const _InvoicesTable({required this.invoices});

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("No hay facturas al contado en este día", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: invoices.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = invoices[index];
        return CustomInvoiceListTile(
          invoice: item,
          onTap: () {
            showInvoiceInspector(context, item);
          },
        );
      },
    );
  }
}
