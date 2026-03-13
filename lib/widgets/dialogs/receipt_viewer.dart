import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/printers/receipt_printer.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';

import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/src/tools/printers/paper_settings.dart';

Future<void> showReceiptViewerDialog(BuildContext context, ReceiptInDb receipt) async {
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _ReceiptViewer(receipt, paperSize: paperSize),
    ),
  );
}

Future<void> showReceiptViewerDialogFromDocNumber(BuildContext context, String docNumber) async {
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<ReceiptInDb>(
          future: context.read<ReceiptsRepository>().getReceiptByDocNumber(docNumber),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (asyncSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Text("Error al cargar el recibo \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final receipt = asyncSnapshot.data!;

            return _ReceiptViewer(receipt, paperSize: paperSize);
          },
        );
      },
    ),
  );
}

class _ReceiptViewer extends StatelessWidget {
  const _ReceiptViewer(this.receipt, {this.paperSize = PaperSize.mm80});

  final ReceiptInDb receipt;
  final PaperSize paperSize;

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
              shareReceipt(receipt, currentBranch, paperSize: paperSize);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Recibo",
            onPressed: () {
              printReceipt(receipt, currentBranch, paperSize: paperSize);
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Ink(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Recibo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "No. ${receipt.docNumber}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Column(
                        children: [
                          Text(
                            DateTimeTool.formatddMMyy(receipt.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            DateTimeTool.formatHHmm(receipt.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentBranch.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Cliente: ${receipt.clientInfo.name}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  Text(
                    "Elaborado por: ${receipt.createdBy.name}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Divider(height: 24),

                  const Text("Facturas Aplicadas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        const Divider(height: 2, thickness: 2),
                        ..._buildInvoiceRows(context, receipt.appliedInvoices),
                        const SizedBox(height: 8),

                        if (receipt.appliedDevolutions.isNotEmpty)
                          const Text(
                            "Devoluciones Aplicadas",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        const SizedBox(height: 8),
                        if (receipt.appliedDevolutions.isNotEmpty) const Divider(height: 2, thickness: 2),
                        ..._buildDevolutionsRows(context, receipt.appliedDevolutions),
                      ],
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
      ),
    );
  }
}

Iterable<Widget> _buildInvoiceRows(BuildContext context, List<AppliedInvoice> invoices) sync* {
  for (var i = 0; i < invoices.length; i++) {
    final currentInvoice = invoices[i];
    final tileColor = i.isOdd ? Colors.white : Colors.grey.shade200;
    yield ListTile(
      tileColor: tileColor,
      minTileHeight: 40,
      onTap: () {
        showInvoiceViewerDialogFromId(context, currentInvoice.invoiceId);
      },
      title: Text(
        "#${currentInvoice.docNumber}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        NumberFormatter.convertToMoneyLike(currentInvoice.amountApplied),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

Iterable<Widget> _buildDevolutionsRows(BuildContext context, List<AppliedDevolution> devolutions) sync* {
  for (var i = 0; i < devolutions.length; i++) {
    final currentDevolutions = devolutions[i];
    final tileColor = i.isOdd ? Colors.white : Colors.grey.shade200;
    yield ListTile(
      tileColor: tileColor,
      minTileHeight: 40,
      onTap: () {
        showDevolutionViewerDialogFromId(context, currentDevolutions.devolutionId);
      },
      title: Text(
        "#${currentDevolutions.docNumber}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        NumberFormatter.convertToMoneyLike(currentDevolutions.amountApplied),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
