import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/custom_invoice_list_tile.dart';
import 'package:kardex_app_front/widgets/custom_receipt_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_inspector.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/title_label.dart';

class CashFlowView extends StatefulWidget {
  final TotalsResult result;

  const CashFlowView({super.key, required this.result});

  @override
  State<CashFlowView> createState() => _CashFlowViewState();
}

class _CashFlowViewState extends State<CashFlowView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final validInvoices = widget.result.detailInvoices.where((e) => e.paymentType != PaymentType.credit).toList();
    final validReceipts = widget.result.detailReceipts;

    final invoicesTotal = validInvoices.fold<int>(0, (prev, e) => prev + e.total);
    final receiptsTotal = validReceipts.fold<int>(0, (prev, e) => prev + e.total);
    final grandTotal = invoicesTotal + receiptsTotal;

    return Column(
      children: [
        _TotalsHeader(
          invoicesTotal: invoicesTotal,
          receiptsTotal: receiptsTotal,
          grandTotal: grandTotal,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                label: Text("Recibos"),
                icon: Icon(Icons.receipt_long),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text("Facturas (Al contado)"),
                icon: Icon(Icons.point_of_sale),
              ),
            ],
            selected: {_currentIndex},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _currentIndex = newSelection.first;
              });
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 4.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _currentIndex == 0
                        ? _ReceiptsTable(receipts: validReceipts)
                        : _InvoicesTable(invoices: validInvoices),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    return Container(
      padding: const EdgeInsets.all(4.0),
      color: Colors.grey.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TitleLabel(
            title: "Total Recibos",
            bigTitle: NumberFormatter.convertToMoneyLike(receiptsTotal),
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          TitleLabel(
            title: "Total Facturas",
            bigTitle: NumberFormatter.convertToMoneyLike(invoicesTotal),
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: Colors.green.shade800),
              child: TitleLabel(
                title: "Ingreso Efectivo Total",
                bigTitle: NumberFormatter.convertToMoneyLike(grandTotal),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
        ],
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
      return const Center(child: Text("No hay recibos"));
    }

    return ListView.separated(
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
      return const Center(child: Text("No hay facturas al contado"));
    }

    return ListView.separated(
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
