import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/printers/devolution_printer.dart';

import 'package:kardex_app_front/src/tools/printers/print_manager.dart';

Future<void> showDevolutionViewerDialog(BuildContext context, DevolutionInDb devolution) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _DevolutionViewer(
          devolution: devolution,
          branch: currentBranch,
          onShare: () => shareDevolution(devolution, currentBranch, paperSize: paperSize),
          onPrint: () => printDevolution(devolution, currentBranch, paperSize: paperSize),
        );
      },
    ),
  );
}

// --- FUNCIÓN PARA NAVEGAR CON SOLO EL ID ---
Future<void> showDevolutionViewerDialogFromId(BuildContext context, String devolutionId) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<DevolutionInDb?>(
          future: context.read<DevolutionsRepository>().getDevolutionById(devolutionId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(child: Text("Error al cargar la devolución \n ${asyncSnapshot.error}")),
              );
            }

            final devolution = asyncSnapshot.data!;

            return _DevolutionViewer(
              devolution: devolution,
              branch: currentBranch,
              onShare: () => shareDevolution(devolution, currentBranch, paperSize: paperSize),
              onPrint: () => printDevolution(devolution, currentBranch, paperSize: paperSize),
            );
          },
        );
      },
    ),
  );
}

// --- EL WIDGET DE VISUALIZACIÓN ---
class _DevolutionViewer extends StatelessWidget {
  const _DevolutionViewer({
    required this.devolution,
    required this.branch,
    this.onShare,
    this.onPrint,
  });

  final DevolutionInDb devolution;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devolución #${devolution.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Compartir Devolución",
            onPressed: onShare,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Devolución",
            onPressed: onPrint,
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // --- SECCIÓN DE ENCABEZADO ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Devolución No. ${devolution.docNumber}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            DateTimeTool.formatddMMyy(devolution.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),

                      Text(
                        "Factura No. ${devolution.originalInvoiceDocNumber}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(branch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        devolution.clientInfo.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Descripcion: ${devolution.description}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),

                  const Divider(),

                  // --- SECCIÓN DE ITEMS DEVUELTOS ---
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
                                child: Text("Producto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              Expanded(
                                child: Text("Cantidad", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              Expanded(
                                child: Text("Precio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              Expanded(
                                child: Text("Subtotal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: devolution.returnedItems.length,
                            itemBuilder: (context, index) {
                              final item = devolution.returnedItems[index];
                              final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                              return Container(
                                padding: const EdgeInsets.all(4),
                                color: rowColor,
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(item.product.name)),
                                    Expanded(child: Text(item.quantity.toString())),
                                    Expanded(child: Text(NumberFormatter.convertToMoneyLike(item.price))),
                                    Expanded(child: Text(NumberFormatter.convertToMoneyLike(item.subTotal))),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // --- SECCIÓN DE TOTAL ---
                  SizedBox(
                    height: 55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Total Devolución:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(devolution.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
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
