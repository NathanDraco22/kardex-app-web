import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

Future<void> showInvoiceInspector(BuildContext context, InvoiceInDb invoice) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _InvoiceInspectorScreen(invoice: invoice, branch: currentBranch);
      },
    ),
  );
}

class _InvoiceInspectorScreen extends StatefulWidget {
  const _InvoiceInspectorScreen({required this.invoice, required this.branch});
  final InvoiceInDb invoice;
  final BranchInDb branch;

  @override
  State<_InvoiceInspectorScreen> createState() => _InvoiceInspectorScreenState();
}

class _InvoiceInspectorScreenState extends State<_InvoiceInspectorScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inspector - Factura #${widget.invoice.docNumber}"),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InvoiceHeader(invoice: widget.invoice, branch: widget.branch),
                const SizedBox(height: 12),
                Center(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text("Detalles por Producto"),
                        icon: Icon(Icons.list_alt),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text("Resumen de Totales"),
                        icon: Icon(Icons.analytics_outlined),
                      ),
                    ],
                    selected: {_selectedIndex},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _selectedIndex = newSelection.first;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _selectedIndex == 0
                      ? _DetailsSegment(saleItems: widget.invoice.saleItems)
                      : _TotalsSegment(saleItems: widget.invoice.saleItems),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  const _InvoiceHeader({required this.invoice, required this.branch});

  final InvoiceInDb invoice;
  final BranchInDb branch;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. ${invoice.docNumber}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateTimeTool.formatddMMyy(invoice.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateTimeTool.formatHHmm(invoice.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              branch.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Builder(
              builder: (context) {
                final label = Text(
                  invoice.paymentType.typeLabel,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );

                if (<PaymentType>[.card, .transfer].contains(invoice.paymentType)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label,
                      Text(
                        " - Ref: ${invoice.bankReference}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }

                return label;
              },
            ),
            const SizedBox(height: 4),
            Text(
              "Cliente: ${invoice.clientInfo.name}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (invoice.clientInfo.location != null && invoice.clientInfo.location!.isNotEmpty)
              Text(
                "${invoice.clientInfo.location}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            if (invoice.clientInfo.address != null && invoice.clientInfo.address!.isNotEmpty)
              Text(
                "${invoice.clientInfo.address}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "Elaborado por: ${invoice.createdBy.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsSegment extends StatelessWidget {
  const _DetailsSegment({required this.saleItems});
  final List<SaleItem> saleItems;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: saleItems.length,
      itemBuilder: (context, index) {
        final item = saleItems[index];

        final totalCost = item.cost * item.quantity;
        final totalPaid = item.total;
        final utility = totalPaid - totalCost;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.qr_code,
                      size: 12,
                    ),
                    Text("${item.product.code}"),
                  ],
                ),
                Text(
                  "Cantidad: ${item.quantity}",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoColumn(
                      label: "Costo Unit.",
                      value: NumberFormatter.convertToMoneyLike(item.cost),
                    ),
                    _InfoColumn(
                      label: "Costo Total",
                      value: NumberFormatter.convertToMoneyLike(totalCost),
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoColumn(
                      label: "Precio Unit.",
                      value: NumberFormatter.convertToMoneyLike(item.price),
                    ),
                    _InfoColumn(
                      label: "Precio Total",
                      value: NumberFormatter.convertToMoneyLike(totalPaid),
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: utility >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: utility >= 0 ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Utilidad del producto:",
                        style: TextStyle(
                          color: utility >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormatter.convertToMoneyLike(utility),
                        style: TextStyle(
                          color: utility >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TotalsSegment extends StatelessWidget {
  const _TotalsSegment({required this.saleItems});
  final List<SaleItem> saleItems;

  @override
  Widget build(BuildContext context) {
    int totalCosto = 0;
    int totalVentas = 0;

    for (final item in saleItems) {
      totalCosto += item.cost * item.quantity;
      totalVentas += item.total;
    }

    final totalGanancia = totalVentas - totalCosto;

    return Center(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Visión Financiera de la Factura",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _TotalRow(
                label: "Total de Costos:",
                value: totalCosto,
                icon: Icons.inventory_2_outlined,
              ),
              const Divider(height: 32),
              _TotalRow(
                label: "Total de Ventas:",
                value: totalVentas,
                icon: Icons.point_of_sale,
              ),
              const Divider(height: 32),
              _TotalRow(
                label: "Total de Ganancias:",
                value: totalGanancia,
                icon: Icons.trending_up,
                isProfit: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isProfit = false,
  });

  final String label;
  final int value;
  final IconData icon;
  final bool isProfit;

  @override
  Widget build(BuildContext context) {
    final color = isProfit ? (value >= 0 ? Colors.green.shade700 : Colors.red.shade700) : Colors.black87;

    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 28),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          NumberFormatter.convertToMoneyLike(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
