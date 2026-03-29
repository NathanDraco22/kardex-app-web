import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/invoice_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/printers/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';

Future<void> showInvoiceViewerDialog(BuildContext context, InvoiceInDb invoice) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _InvoiceViewer(
          invoice: invoice,
          branch: currentBranch,
          onShare: () => shareInvoice(invoice, currentBranch, paperSize: paperSize),
          onPrint: () => printInvoice(invoice, currentBranch, paperSize: paperSize),
        );
      },
    ),
  );
}

Future<void> showInvoiceViewerDialogFromId(BuildContext context, String invoiceId) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder(
          future: context.read<InvoicesRepository>().getInvoiceById(invoiceId),
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
                  child: Text("Error al cargar la factura \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final invoice = asyncSnapshot.data!;

            return _InvoiceViewer(
              invoice: invoice,
              branch: currentBranch,
              onShare: () => shareInvoice(invoice, currentBranch, paperSize: paperSize),
              onPrint: () => printInvoice(invoice, currentBranch, paperSize: paperSize),
            );
          },
        );
      },
    ),
  );
}

class _InvoiceViewer extends StatelessWidget {
  const _InvoiceViewer({
    required this.invoice,
    required this.branch,
    this.onShare,
    this.onPrint,
  });

  final InvoiceInDb invoice;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Factura #${invoice.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Compartir Factura",
            onPressed: onShare,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Factura",
            onPressed: onPrint,
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: InvoiceViewerContent(
                invoice: invoice,
                branch: branch,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InvoiceViewerContent extends StatelessWidget {
  const InvoiceViewerContent({
    super.key,
    required this.invoice,
    required this.branch,
  });

  final InvoiceInDb invoice;
  final BranchInDb branch;

  @override
  Widget build(BuildContext context) {
    final totalDiscount = invoice.saleItems.fold(
      0,
      (previousValue, element) => previousValue + element.totalDiscount,
    );
    final invoiceSubTotal = invoice.saleItems.fold(
      0,
      (element, previousValue) => previousValue.subTotal + element,
    );
    return Column(
      children: [
        const Text(
          "Factura",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Column(
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );

                if (<PaymentType>[.card, .transfer].contains(invoice.paymentType)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label,
                      Text(
                        " - Ref: ${invoice.bankReference}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }

                return label;
              },
            ),

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

            Row(
              children: [
                Text(
                  "Elaborado por: ${invoice.createdBy.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),

            if (invoice.description.isNotEmpty)
              Text(
                "Observación: ${invoice.description}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
          ],
        ),
        const Divider(),
        Flexible(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Producto",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Cant.",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Precio",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: invoice.saleItems.length,
                  itemBuilder: (context, index) {
                    final saleItem = invoice.saleItems[index];
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                    return Container(
                      padding: const EdgeInsets.all(4),
                      color: rowColor,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(saleItem.product.name),
                          ),
                          Expanded(
                            child: Text(
                              saleItem.quantity.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(saleItem.price),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(saleItem.subTotal),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              SizedBox(
                height: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "SubTotal:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(invoiceSubTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Total Descuento:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(totalDiscount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(invoice.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
