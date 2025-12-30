import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/exit_history/exit_history_model.dart';
import 'package:kardex_app_front/src/domain/repositories/exit_histories_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

// --- FUNCIÓN PARA NAVEGAR CON EL MODELO COMPLETO ---
Future<void> showExitHistoryViewerDialog(BuildContext context, ExitHistoryInDb exitHistory) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _ExitHistoryViewer(
          exitHistory: exitHistory,
          branch: currentBranch,
        );
      },
    ),
  );
}

// --- FUNCIÓN PARA NAVEGAR CON SOLO EL ID ---
Future<void> showExitHistoryViewerDialogFromId(BuildContext context, String exitHistoryId) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<ExitHistoryInDb?>(
          future: context.read<ExitHistoriesRepository>().getExitHistoryById(exitHistoryId),
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

            final exitHistory = asyncSnapshot.data!;

            return _ExitHistoryViewer(
              exitHistory: exitHistory,
              branch: currentBranch,
            );
          },
        );
      },
    ),
  );
}

// --- EL WIDGET DE VISUALIZACIÓN ---
class _ExitHistoryViewer extends StatelessWidget {
  const _ExitHistoryViewer({
    required this.exitHistory,
    required this.branch,
    this.onShare,
    this.onPrint,
  });

  final ExitHistoryInDb exitHistory;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de Salida #${exitHistory.docNumber}"),
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
                  const Text(
                    "Salida de Inventario",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "No. ${exitHistory.docNumber}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            DateTimeTool.formatddMMyy(exitHistory.docDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Sucursal: ${branch.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      Text(
                        "Cliente: ${exitHistory.client.name}",
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                      if (exitHistory.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Descripción: ${exitHistory.description}",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Elaborado por:",
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              ),

                              Text(
                                exitHistory.createdBy.name,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                DateTimeTool.formatddMMyy(exitHistory.createdAt),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Text(" | "),
                              Text(
                                DateTimeTool.formatHHmm(exitHistory.createdAt),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                            itemCount: exitHistory.items.length,
                            itemBuilder: (context, index) {
                              final item = exitHistory.items[index];
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

                                        children: [
                                          Text(
                                            item.productName,
                                          ),
                                          Row(
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
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.quantity.toString(),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.convertToMoneyLike(item.cost ?? 0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        NumberFormatter.convertToMoneyLike(
                                          (item.cost ?? 0) * item.quantity.abs(),
                                        ),
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
                              NumberFormatter.convertToMoneyLike(exitHistory.total),
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
