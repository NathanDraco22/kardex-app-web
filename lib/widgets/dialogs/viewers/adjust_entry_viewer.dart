import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_adjust_entry_template.dart';

Future<void> showAdjustEntryViewerDialog(BuildContext context, AdjustEntryInDb adjustEntry) async {
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _AdjustEntryViewer(
          adjustEntry: adjustEntry,
          branch: currentBranch,
          onExportPdf: () async {
            final template = SingleAdjustEntryTemplate(adjustEntry: adjustEntry, branch: currentBranch);
            await PdfExportTool.export(template, fileName: "entrada_ajuste_${adjustEntry.docNumber}.pdf");
          },
        );
      },
    ),
  );
}

Future<void> showAdjustEntryViewerDialogFromId(BuildContext context, String adjustEntryId) async {
  final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<AdjustEntryInDb?>(
          future: context.read<AdjustEntriesRepository>().getAdjustEntryById(adjustEntryId),
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
                body: Center(child: Text("Error al cargar el ajuste \n ${asyncSnapshot.error}")),
              );
            }

            final adjustEntry = asyncSnapshot.data!;

            return _AdjustEntryViewer(
              adjustEntry: adjustEntry,
              branch: currentBranch,
              onExportPdf: () async {
                final template = SingleAdjustEntryTemplate(adjustEntry: adjustEntry, branch: currentBranch);
                await PdfExportTool.export(template, fileName: "entrada_ajuste_${adjustEntry.docNumber}.pdf");
              },
            );
          },
        );
      },
    ),
  );
}

class _AdjustEntryViewer extends StatelessWidget {
  const _AdjustEntryViewer({
    required this.adjustEntry,
    required this.branch,
    this.onExportPdf,
  });

  final AdjustEntryInDb adjustEntry;
  final BranchInDb branch;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    // Calculate total on the fly
    final total = adjustEntry.items.fold<int>(0, (prev, item) {
      return prev + (item.cost * item.quantity);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Ajuste de Entrada #${adjustEntry.docNumber}"),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Entrada por Ajuste",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No. ${adjustEntry.docNumber}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          // AdjustEntryInDb stores creation time in createdAt (int epoch),
                          // but usually documents have a docDate.
                          // The model only has createdAt. I'll use that.
                          Text(
                            DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(adjustEntry.createdAt)),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Sucursal: ${branch.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      if (adjustEntry.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Descripción: ${adjustEntry.description}",
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
                                adjustEntry.createdBy.name,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(adjustEntry.createdAt)),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const Text(" | "),
                              Text(
                                DateTimeTool.formatHHmm(DateTime.fromMillisecondsSinceEpoch(adjustEntry.createdAt)),
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
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Costo",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Subtotal",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: adjustEntry.items.length,
                            itemBuilder: (context, index) {
                              final item = adjustEntry.items[index];
                              final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                color: rowColor,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(item.productName),
                                          Row(
                                            children: [
                                              Text(item.code ?? ""),
                                              const SizedBox(width: 4),
                                              Text(item.brandName ?? ""),
                                              const SizedBox(width: 4),
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
                              NumberFormatter.convertToMoneyLike(total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
