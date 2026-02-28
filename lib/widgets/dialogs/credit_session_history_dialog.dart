import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/receipt_history/read_receipt_history_cubit.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/repositories/receipt_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';

Future<void> showCreditSessionHistoryDialog(BuildContext context, ClientInDb client) async {
  await showDialog(
    context: context,
    builder: (context) => CreditSessionHistoryDialog(client: client),
  );
}

class CreditSessionHistoryDialog extends StatelessWidget {
  const CreditSessionHistoryDialog({super.key, required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ReadReceiptHistoryCubit(context.read<ReceiptsRepository>());
        cubit.params.clientId = client.id;
        cubit.params.startDate = client.lastCreditStart;
        cubit.loadReceiptsHistory();
        return cubit;
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Historial de Sesión de Crédito",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  client.name,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (client.lastCreditStart != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Desde: ${DateTimeTool.formatddMMyy(client.lastCreditStart!)}",
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ReadReceiptHistoryCubit, ReadReceiptHistoryState>(
                    builder: (context, state) {
                      if (state is ReadReceiptHistoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ReadReceiptHistoryError) {
                        return Center(
                          child: Text("Error al cargar abonos: ${state.message}"),
                        );
                      }

                      if (state is ReadReceiptHistorySuccess || state is FetchingNextPage) {
                        final receipts = (state is ReadReceiptHistorySuccess)
                            ? state.receipts
                            : (state as FetchingNextPage).receipts;

                        if (receipts.isEmpty) {
                          return const Center(child: Text("No hay abonos registrados en este ciclo."));
                        }

                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                              context.read<ReadReceiptHistoryCubit>().nextPage();
                            }
                            return true;
                          },
                          child: ListView.separated(
                            itemCount: receipts.length + (state is FetchingNextPage ? 1 : 0),
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              if (index >= receipts.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final receipt = receipts[index];
                              return ListTile(
                                leading: const Icon(Icons.receipt_long, color: Colors.blue),
                                title: Text("Recibo #${receipt.docNumber}"),
                                subtitle: Text(DateTimeTool.formatddMMyy(receipt.createdAt)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      NumberFormatter.convertToMoneyLike(receipt.total),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                  ],
                                ),
                                onTap: () {
                                  showReceiptViewerDialog(context, receipt);
                                },
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cerrar"),
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
