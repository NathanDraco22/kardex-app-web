import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/entry_history/entry_history_model.dart';
import 'package:kardex_app_front/src/domain/repositories/entry_histories_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

// --- FUNCIÓN PARA NAVEGAR CON EL MODELO COMPLETO ---
Future<void> showEntryHistoryViewerDialog(BuildContext context, EntryHistoryInDb entryHistory) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _EntryHistoryViewer(
          entryHistory: entryHistory,
          branch: currentBranch,
        );
      },
    ),
  );
}

// --- FUNCIÓN PARA NAVEGAR CON SOLO EL ID ---
Future<void> showEntryHistoryViewerDialogFromId(BuildContext context, String entryHistoryId) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;

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
    this.onShare,
    this.onPrint,
  });

  final EntryHistoryInDb entryHistory;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de Entrada #${entryHistory.docNumber}"),
        actions: [
          IconButton(tooltip: "Compartir", onPressed: onShare, icon: const Icon(Icons.share)),
          IconButton(tooltip: "Imprimir", onPressed: onPrint, icon: const Icon(Icons.print)),
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
                                          Text(
                                            item.productName,
                                          ),
                                          Row(
                                            spacing: 4,
                                            children: [
                                              Text(
                                                item.code ?? "",
                                              ),
                                              Text(
                                                item.brandName ?? "",
                                              ),
                                              Text(
                                                item.unitName ?? "",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ), // Asumiendo que necesitas obtener el nombre
                                    Expanded(
                                      child: Text(
                                        item.quantity.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.convertToMoneyLike(item.cost),
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
