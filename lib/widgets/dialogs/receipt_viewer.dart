import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/printers/receipt_printer.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

Future<void> showReceiptViewerDialog(BuildContext context, ReceiptInDb receipt) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _ReceiptViewer(receipt),
    ),
  );
}

class _ReceiptViewer extends StatelessWidget {
  const _ReceiptViewer(this.receipt);

  final ReceiptInDb receipt;

  @override
  Widget build(BuildContext context) {
    // Asumimos que obtienes la sucursal del AuthCubit
    final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;

    return Scaffold(
      appBar: AppBar(
        title: Text("Recibo #${receipt.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Compartir Recibo",
            onPressed: () {
              shareReceipt(receipt, currentBranch);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Recibo",
            onPressed: () {
              printReceipt(receipt, currentBranch);
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recibo No. ${receipt.docNumber}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateTimeTool.formatddMMyy(receipt.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(currentBranch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(receipt.clientInfo.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(height: 24),

                const Text("Facturas Aplicadas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: receipt.appliedInvoices.length,
                    itemBuilder: (context, index) {
                      final appliedInvoice = receipt.appliedInvoices[index];
                      return ListTile(
                        title: Text("#${appliedInvoice.docNumber}"),
                        trailing: Text(NumberFormatter.convertToMoneyLike(appliedInvoice.amountApplied)),
                      );
                    },
                  ),
                ),
                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Total Recibo:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(width: 16),
                    Text(
                      NumberFormatter.convertToMoneyLike(receipt.total),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
