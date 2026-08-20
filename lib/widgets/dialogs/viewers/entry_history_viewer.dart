import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_entry_history_template.dart';

// --- FUNCIÓN PARA NAVEGAR CON EL MODELO COMPLETO ---
Future<void> showEntryHistoryViewerDialog(BuildContext context, EntryHistoryInDb entryHistory) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _EntryHistoryViewer(
          entryHistory: entryHistory,
          branch: currentBranch,
          onExportPdf: () async {
            final template = SingleEntryHistoryTemplate(entryHistory: entryHistory, branch: currentBranch);
            await PdfExportTool.export(template, fileName: "entrada_inventario_${entryHistory.docNumber}.pdf");
          },
        );
      },
    ),
  );
}

// --- FUNCIÓN PARA NAVEGAR CON SOLO EL ID ---
Future<void> showEntryHistoryViewerDialogFromId(BuildContext context, String entryHistoryId) async {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<EntryHistoryInDb?>(
          future: context.read<EntryHistoriesRepository>().getEntryHistoryById(entryHistoryId),
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
                body: Center(child: Text("Error al cargar el historial \n ${asyncSnapshot.error}")),
              );
            }

            final entryHistory = asyncSnapshot.data!;

            return _EntryHistoryViewer(
              entryHistory: entryHistory,
              branch: currentBranch,
              onExportPdf: () async {
                final template = SingleEntryHistoryTemplate(entryHistory: entryHistory, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "entrada_inventario_${entryHistory.docNumber}.pdf");
              },
            );
          },
        );
      },
    ),
  );
}

// --- EL WIDGET DE VISUALIZACIÓN ---
class _EntryHistoryViewer extends StatelessWidget {
  const _EntryHistoryViewer({
    required this.entryHistory,
    required this.branch,
    this.onExportPdf,
  });

  final EntryHistoryInDb entryHistory;
  final BranchInDb branch;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de Entrada #${entryHistory.docNumber}"),
        actions: [
          IconButton(tooltip: "Exportar PDF (A4)", onPressed: onExportPdf, icon: const Icon(Icons.picture_as_pdf)),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // --- SECCIÓN DE ENCABEZADO ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Entrada de Inventario",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No. ${entryHistory.docNumber}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            DateTimeTool.formatddMMyy(entryHistory.docDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Sucursal: ${branch.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      Text(
                        "Proveedor: ${entryHistory.supplier.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      if (entryHistory.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Descripción: ${entryHistory.description}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Elaborado por:",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              ),

                              Text(
                                entryHistory.createdBy.name,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                DateTimeTool.formatddMMyy(entryHistory.createdAt),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Text(" | "),
                              Text(
                                DateTimeTool.formatHHmm(entryHistory.createdAt),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),

                  // --- SECCIÓN DE ITEMS ---
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Cantidad",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Costo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Subtotal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: entryHistory.items.length,
                            itemBuilder: (context, index) {
                              final item = entryHistory.items[index];
                              final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                color: rowColor,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.qr_code, size: 12),
                                              Text(
                                                item.code ?? "",
                                              ),
                                            ],
                                          ),
                                          Text(
                                            item.productName,
                                            style: const TextStyle(fontWeight: .w600),
                                          ),
                                          Row(
                                            spacing: 4,
                                            children: [
                                              Text(
                                                item.brandName ?? "",
                                              ),
                                              Text(
                                                "${item.unitName ?? ''}${item.conversionFactor > 1 ? ' (${item.conversionFactor % 1 == 0 ? item.conversionFactor.toInt() : item.conversionFactor})' : ''}",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.formatDisplayStock(item.quantity, item.conversionFactor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.convertToMoneyLike(item.cost * item.conversionFactor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.convertToMoneyLike(item.cost * item.quantity),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(
                              width: 100,
                              child: Text(
                                "Total:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              NumberFormatter.convertToMoneyLike(entryHistory.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
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
