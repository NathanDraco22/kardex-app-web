import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/repositories/order_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/printers/order_printer.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

import 'package:kardex_app_front/src/tools/printers/print_manager.dart';

Future<void> showOrderViewerDialog(BuildContext context, OrderInDb order) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return _OrderViewer(
          order: order,
          branch: currentBranch,
          onShare: () => shareOrder(order, currentBranch, paperSize: paperSize),
          onPrint: () => printOrder(order, currentBranch, paperSize: paperSize),
        );
      },
    ),
  );
}

Future<void> showOrderViewerDialogFromId(BuildContext context, String orderId) async {
  final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;
  final paperSize = await PrintManager.getLocalPaperSize();
  if (!context.mounted) return;

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder(
          future: context.read<OrdersRepository>().getOrderById(orderId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Text("Error al cargar el pedido \n ${asyncSnapshot.error ?? 'Pedido no encontrado'}"),
                ),
              );
            }

            final order = asyncSnapshot.data!;

            return _OrderViewer(
              order: order,
              branch: currentBranch,
              onShare: () => shareOrder(order, currentBranch, paperSize: paperSize),
              onPrint: () => printOrder(order, currentBranch, paperSize: paperSize),
            );
          },
        );
      },
    ),
  );
}

class _OrderViewer extends StatelessWidget {
  const _OrderViewer({
    required this.order,
    required this.branch,
    this.onShare,
    this.onPrint,
  });

  final OrderInDb order;
  final BranchInDb branch;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido #${order.docNumber}"),
        actions: [
          IconButton(
            tooltip: "Compartir Pedido",
            onPressed: onShare,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            tooltip: "Imprimir Pedido",
            onPressed: onPrint,
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: OrderViewerContent(
                order: order,
                branch: branch,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderViewerContent extends StatelessWidget {
  const OrderViewerContent({
    super.key,
    required this.order,
    required this.branch,
  });

  final OrderInDb order;
  final BranchInDb branch;

  @override
  Widget build(BuildContext context) {
    final totalDiscount = order.saleItems.fold(
      0,
      (previousValue, element) => previousValue + element.totalDiscount,
    );
    final orderSubTotal = order.saleItems.fold(
      0,
      (element, previousValue) => previousValue.subTotal + element,
    );
    return Column(
      children: [
        const Text(
          "Pedido",
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No. ${order.docNumber}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      DateTimeTool.formatddMMyy(order.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateTimeTool.formatHHmm(order.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              branch.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Builder(
              builder: (context) {
                return Text(
                  order.paymentType.typeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            Text(
              "Cliente: ${order.clientInfo.name}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            if (order.clientInfo.location != null && order.clientInfo.location!.isNotEmpty)
              Text(
                "${order.clientInfo.location}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

            if (order.clientInfo.address != null && order.clientInfo.address!.isNotEmpty)
              Text(
                "${order.clientInfo.address}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

            Row(
              children: [
                Text(
                  "Elaborado por: ${order.createdBy.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      flex: 4,
                      child: Text(
                        "Producto",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Cant.",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Precio",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: order.saleItems.length,
                  itemBuilder: (context, index) {
                    final saleItem = order.saleItems[index];
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                    return Container(
                      padding: const EdgeInsets.all(4),
                      color: rowColor,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              saleItem.product.name,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              saleItem.quantity.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(saleItem.price),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(saleItem.subTotal),
                              textAlign: TextAlign.center,
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
                height: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "SubTotal:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(orderSubTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Total Descuento:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          width: 120,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(totalDiscount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              NumberFormatter.convertToMoneyLike(order.total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
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
      ],
    );
  }
}
