import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/invoice_printer.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

Future<void> showInvoiceViewerDialog(BuildContext context, InvoiceInDb invoice) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _InvoiceViewer(invoice),
    ),
  );
}

class _InvoiceViewer extends StatelessWidget {
  const _InvoiceViewer(
    this.invoice,
  );

  final InvoiceInDb invoice;

  @override
  Widget build(BuildContext context) {
    final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
    return Scaffold(
      appBar: AppBar(
        title: Text("Factura #${invoice.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Compartir Factura",
            onPressed: () {
              shareInvoice(invoice, currentBranch);
            },
            icon: const Icon(Icons.share),
          ),

          IconButton(
            tooltip: "Imprimir Factura",
            onPressed: () {
              printInvoice(invoice, currentBranch);
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Factura",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "No. ${invoice.docNumber}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              const Text(
                                "Fecha",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                DateTimeTool.formatddMMyy(invoice.createdAt),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Text(
                        "MR Farmacos",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),

                      const Text(
                        "Cliente: Nombre del cliente por completo",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  flex: 3,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Producto",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Cantidad",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Precio",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Total",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

                            return Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(saleItem.product.name),
                                ),
                                Expanded(child: Text(saleItem.quantity.toString())),
                                Expanded(
                                  child: Text(
                                    NumberFormatter.convertToMoneyLike(
                                      saleItem.price,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    NumberFormatter.convertToMoneyLike(
                                      saleItem.subTotal,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Descuentos: C\$0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Descuentos: C\$0",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Total: ${NumberFormatter.convertToMoneyLike(invoice.total)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
