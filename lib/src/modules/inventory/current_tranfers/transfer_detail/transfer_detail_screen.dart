import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/current_tranfers/modals/cancel_transfer_modal.dart';
import 'package:kardex_app_front/src/modules/inventory/current_tranfers/modals/receive_transfer_modal.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

Future<void> showTransferDetailScreen(BuildContext context, TransferInDb transfer) async {
  final repo = context.read<TransfersRepository>();
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => WriteTransferCubit(repository: repo),
        child: TransferDetailScreen(transfer: transfer),
      ),
    ),
  );
}

class TransferDetailScreen extends StatelessWidget {
  const TransferDetailScreen({super.key, required this.transfer});

  final TransferInDb transfer;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteTransferCubit, WriteTransferState>(
      listener: (context, state) {
        if (state is WriteTransferLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        } else {
          LoadingDialogManager.closeLoadingDialog(context);
        }

        if (state is WriteTransferSuccess) {
          DialogManager.showInfoDialog(context, "Operación exitosa");
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }

        if (state is WriteTransferFailure) {
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Transferencia ${transfer.docNumber}"),
        ),
        body: _Body(transfer: transfer),
        bottomNavigationBar: _BottomBar(transfer: transfer),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.transfer});

  final TransferInDb transfer;

  @override
  Widget build(BuildContext context) {
    String originName;
    try {
      originName = BranchesTool.getBranchById(transfer.origin).name;
    } catch (_) {
      originName = transfer.origin;
    }

    String destName;
    try {
      destName = BranchesTool.getBranchById(transfer.destination).name;
    } catch (_) {
      destName = transfer.destination;
    }

    final date = DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(transfer.createdAt));
    final totalForamatted = NumberFormatter.convertToMoneyLike(transfer.costTotal);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _RowInfo("Fecha", date),
                      _RowInfo("Origen", originName),
                      _RowInfo("Destino", destName),
                      _RowInfo("Estado", transfer.status.label),
                      if (transfer.description.isNotEmpty) _RowInfo("Descripción", transfer.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: BasicTableListView(
                            itemCount: transfer.items.length,
                            columns: [
                              BasicTableColumn(label: const Text("Producto"), flex: 2),
                              BasicTableColumn(label: const Text("Cant."), flex: 1),
                              BasicTableColumn(label: const Text("Costo"), flex: 1),
                              BasicTableColumn(label: const Text("Total"), flex: 1),
                            ],
                            rowBuilder: (context, index) {
                              final item = transfer.items[index];
                              final rowColor = index.isEven ? Colors.grey.shade200 : Colors.white;

                              String expirationTag = "--";
                              final expirationDate = item.expirationDate;
                              if (expirationDate != null) {
                                final expiration = DateTime.fromMillisecondsSinceEpoch(expirationDate);
                                expirationTag = DateTimeTool.formatMMyy(expiration);
                              }
                              return BasicTableRow(
                                color: rowColor,
                                cells: [
                                  BasicTableCell(
                                    content: Column(
                                      spacing: 4,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          spacing: 8,
                                          children: [
                                            Text(item.brandName),
                                            Text(item.unitName),
                                          ],
                                        ),
                                        Text(
                                          "Venc: $expirationTag",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  BasicTableCell(
                                    content: Text(
                                      item.quantity.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  BasicTableCell(
                                    content: Text(
                                      NumberFormatter.convertToMoneyLike(item.cost),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  BasicTableCell(
                                    content: Text(
                                      NumberFormatter.convertToMoneyLike(item.cost * item.quantity),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const Divider(
                          height: 4.0,
                        ),
                        Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Total:",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              totalForamatted,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
    );
  }
}

class _RowInfo extends StatelessWidget {
  const _RowInfo(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.transfer});
  final TransferInDb transfer;

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.watch<WriteTransferCubit>();
    final currentBranchId = BranchesTool.getCurrentBranchId();

    TransferInDb currentTransfer = transfer;
    if (writeCubit.state is WriteTransferSuccess) {
      currentTransfer = (writeCubit.state as WriteTransferSuccess).transfer;
    }

    final isOrigin = currentBranchId == currentTransfer.origin;
    final isDest = currentBranchId == currentTransfer.destination;
    final isInTransit = currentTransfer.status == TransferStatus.inTransit;

    Widget? actionButton;

    if (isInTransit) {
      if (isDest) {
        actionButton = ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final confirm = await showReceiveTransferModal(context, currentTransfer);
            if (confirm != true) return;

            if (!context.mounted) return;
            final userWithRole = SessionTool.getUserFrom(context);
            if (userWithRole == null) return;

            final intent = ReceiveTransferIntent(
              receivedAt: DateTime.now().millisecondsSinceEpoch,
              receivedBy: UserInfo(id: userWithRole.id, name: userWithRole.username),
            );
            writeCubit.receiveTransfer(currentTransfer.id, intent);
          },
          icon: const Icon(Icons.check),
          label: const Text("Recibir Mercadería"),
        );
      } else if (isOrigin) {
        actionButton = ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final confirm = await showCancelTransferModal(context, currentTransfer);
            if (confirm != true) return;

            if (!context.mounted) return;
            final userWithRole = SessionTool.getUserFrom(context);
            if (userWithRole == null) return;

            final intent = CancelTransferIntent(
              cancelledAt: DateTime.now().millisecondsSinceEpoch,
              cancelledBy: UserInfo(id: userWithRole.id, name: userWithRole.username),
            );
            writeCubit.cancelTransfer(currentTransfer.id, intent);
          },
          icon: const Icon(Icons.cancel),
          label: const Text("Cancelar Transferencia"),
        );
      }
    } else {
      Color color = Colors.grey;
      if (currentTransfer.status == TransferStatus.received) color = Colors.green;
      if (currentTransfer.status == TransferStatus.cancelled) color = Colors.red;

      actionButton = Text(
        currentTransfer.status.label.toUpperCase(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      );
    }

    if (actionButton == null) return const SizedBox.shrink();

    return BottomAppBar(
      height: 70,
      child: Center(child: actionButton),
    );
  }
}
