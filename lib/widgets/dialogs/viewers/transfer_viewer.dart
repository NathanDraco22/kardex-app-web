import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

Future<void> showTransferViewerDialog(BuildContext context, TransferInDb transfer) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _TransferViewer(
          transfer: transfer,
        );
      },
    ),
  );
}

Future<void> showTransferViewerDialogFromId(BuildContext context, String transferId) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder(
          future: context.read<TransfersRepository>().getTransferById(transferId),
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
                  child: Text("Error al cargar la transferencia \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final transfer = asyncSnapshot.data!;

            return _TransferViewer(
              transfer: transfer,
            );
          },
        );
      },
    ),
  );
}

class _TransferViewer extends StatelessWidget {
  const _TransferViewer({
    required this.transfer,
  });

  final TransferInDb transfer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transferencia #${transfer.docNumber}"),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: TransferViewerContent(
                transfer: transfer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransferViewerContent extends StatelessWidget {
  const TransferViewerContent({
    super.key,
    required this.transfer,
  });

  final TransferInDb transfer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Transferencia de Inventario",
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
                Text(
                  "No. ${transfer.docNumber}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      DateTimeTool.formatddMMyy(DateTime.fromMillisecondsSinceEpoch(transfer.createdAt)),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Origen: ${transfer.originName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "Destino: ${transfer.destinationName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Estado: ${transfer.status.label}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (transfer.description.isNotEmpty) Text("Nota: ${transfer.description}"),

            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Elaborado por: ${transfer.createdBy.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Costo",
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
                  itemCount: transfer.items.length,
                  itemBuilder: (context, index) {
                    final item = transfer.items[index];
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                    return Container(
                      padding: const EdgeInsets.all(4),
                      color: rowColor,
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(item.name)),
                          Expanded(child: Text(item.quantity.toString())),
                          Expanded(
                            child: Text(
                              NumberFormatter.convertToMoneyLike(item.cost),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              NumberFormatter.convertToMoneyLike(item.cost * item.quantity),
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
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Total:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      NumberFormatter.convertToMoneyLike(transfer.costTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
