import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

import 'package:kardex_app_front/src/tools/printers/devolution_printer.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_devolution_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/widgets/elements/devolution_status_chip.dart';

import 'package:kardex_app_front/src/tools/printers/print_manager.dart';

Future<void> showDevolutionViewerDialog(BuildContext context, DevolutionInDb devolution) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
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
          onExportPdf: () async {
            final template = SingleDevolutionTemplate(devolution: devolution, branch: currentBranch);
            await PdfExportTool.export(template, fileName: "devolucion_${devolution.docNumber}.pdf");
          },
        );
      },
    ),
  );
}

// --- FUNCIÓN PARA NAVEGAR CON SOLO EL ID ---
Future<void> showDevolutionViewerDialogFromId(BuildContext context, String devolutionId) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
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
              onExportPdf: () async {
                final template = SingleDevolutionTemplate(devolution: devolution, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "devolucion_${devolution.docNumber}.pdf");
              },
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
    this.onExportPdf,
  });

  final DevolutionInDb devolution;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Devolución #${devolution.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Exportar PDF (A4)",
            onPressed: onExportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DevolutionStatusChip(status: devolution.status),
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
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(item.product.name),
                                          Text(
                                            "${item.product.unitName}${item.conversionFactor > 1 ? ' (${item.conversionFactor % 1 == 0 ? item.conversionFactor.toInt() : item.conversionFactor})' : ''}",
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.conversionFactor != 1
                                            ? (item.quantity ~/ item.conversionFactor).toString()
                                            : item.quantity.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.convertToMoneyLike(item.price * item.conversionFactor),
                                      ),
                                    ),
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
