import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/write_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/modals/cancel_order_invoice_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/modals/confirm_order_invoice_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/row_widgets/sale_item_row.dart';

Future<OrderInDb?> showOrderInvoiceCreatorDialog(BuildContext context, OrderInDb order) async {
  final readCubit = context.read<ReadOrderCubit>();
  return await Navigator.push<OrderInDb?>(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: readCubit,
        child: InvoiceCreatorScreen(order: order),
      ),
    ),
  );
}

class OrderContainer {
  OrderInDb order;

  OrderContainer({required this.order});

  void updateOrder(OrderInDb order) {
    this.order = order;
  }
}

class InvoiceCreateMediator extends InheritedWidget {
  const InvoiceCreateMediator({super.key, required super.child, required this.orderContainer});

  final OrderContainer orderContainer;

  static InvoiceCreateMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InvoiceCreateMediator>()!;
  }

  @override
  bool updateShouldNotify(InvoiceCreateMediator oldWidget) {
    return false;
  }
}

class InvoiceCreatorScreen extends StatelessWidget {
  const InvoiceCreatorScreen({super.key, required this.order});

  final OrderInDb order;

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    return InvoiceCreateMediator(
      orderContainer: OrderContainer(order: order),
      child: BlocProvider(
        create: (context) => WriteOrderCubit(
          ordersRepository: orderRepo,
        ),
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final orderContainer = InvoiceCreateMediator.of(context).orderContainer;
    final writeCubit = context.read<WriteOrderCubit>();
    return BlocListener<WriteOrderCubit, WriteOrderState>(
      listener: (context, state) async {
        if (state is WriteOrderInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteOrderError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteOrderSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          final resultOrder = state.order;
          String message = "Orden facturada con éxito";
          if (resultOrder.status == OrderStatus.cancelled) message = "Orden cancelada con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          final readCubit = context.read<ReadOrderCubit>();
          await readCubit.updateOrderCache(state.order);
          if (!context.mounted) return;
          Navigator.pop(context, state.order);
        }

        if (state is WriteOrderToInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          String message = "Orden facturada con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          final readCubit = context.read<ReadOrderCubit>();
          await readCubit.updateOrderCache(state.order);

          if (!context.mounted) return;
          await showInvoiceViewerDialog(context, state.invoice);
          if (!context.mounted) return;
          Navigator.pop(context, state.order);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Facturar Orden")),
        body: const _Body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(
          builder: (context) {
            if (orderContainer.order.status == OrderStatus.open) {
              return const SizedBox.shrink();
            }

            if (orderContainer.order.invoiceId.isEmpty) {
              return const SizedBox.shrink();
            }

            return ElevatedButton.icon(
              onPressed: () {
                showInvoiceViewerDialogFromId(context, orderContainer.order.invoiceId);
              },
              label: const Text("Ver Factura"),
              icon: const Icon(Icons.picture_as_pdf),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Builder(
            builder: (context) {
              if (orderContainer.order.status != OrderStatus.open) {
                final textColor = orderContainer.order.status == OrderStatus.completed ? Colors.green : Colors.red;
                return Center(
                  child: Text(
                    orderContainer.order.status.tag.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                    ),
                    onPressed: () async {
                      final res = await showCancelOrderInvoiceModal(context, orderContainer.order);
                      if (res != true) return;
                      writeCubit.cancelOrder(orderContainer.order.id);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar Orden"),
                  ),
                  const SizedBox(width: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade300,
                    ),
                    onPressed: () async {
                      final res = await showConfirmOrderInvoiceModal(context, orderContainer.order);
                      if (res != true) return;
                      writeCubit.convertOrderToInvoice(orderContainer.order.id);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Facturar Orden"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  List<SaleItem> markedItems = [];
  OrderInDb? _currentOrder;
  bool? _isAscending;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrder ??= InvoiceCreateMediator.of(context).orderContainer.order;
  }

  void _toggleSort() {
    if (_currentOrder == null) return;
    final nextAscending = !(_isAscending ?? false);

    final sortedItems = List<SaleItem>.from(_currentOrder!.saleItems);
    sortedItems.sort((a, b) {
      final nameA = a.product.name.toLowerCase();
      final nameB = b.product.name.toLowerCase();
      return nextAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    final updatedOrder = _currentOrder!.copyWith(saleItems: sortedItems);

    InvoiceCreateMediator.of(context).orderContainer.updateOrder(updatedOrder);

    setState(() {
      _currentOrder = updatedOrder;
      _isAscending = nextAscending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentOrder == null) return const SizedBox.shrink();
    final order = _currentOrder!;
    final saleItems = order.saleItems;
    final totalFormatted = NumberFormatter.convertToMoneyLike(order.total);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Orden: ${order.docNumber}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Text(
                            DateTimeTool.formatddMMyy(order.createdAt),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          String paymentType = "CREDITO";

                          if (order.paymentType == PaymentType.cash) {
                            paymentType = "CONTADO";
                          }

                          return Text(
                            paymentType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),

                      Text(
                        order.clientInfo.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      Text(
                        order.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Total: $totalFormatted",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Detalle:",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            IconButton(
                              tooltip: _isAscending == null
                                  ? "Ordenar productos (A-Z)"
                                  : _isAscending!
                                  ? "Ordenar Z-A"
                                  : "Ordenar A-Z",
                              icon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sort_by_alpha, size: 20),
                                  if (_isAscending != null)
                                    Icon(
                                      _isAscending! ? Icons.arrow_downward : Icons.arrow_upward,
                                      size: 14,
                                    ),
                                ],
                              ),
                              onPressed: _toggleSort,
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              const Divider(),
                              ..._buildSaleItemRows(saleItems, markedItems),
                            ],
                          ),
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

  Iterable<Widget> _buildSaleItemRows(
    List<SaleItem> saleItems,
    List<SaleItem> markedItems,
  ) sync* {
    for (var i = 0; i < saleItems.length; i++) {
      final saleItem = saleItems[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;

      yield SaleItemRow(
        saleItem: saleItem,
        color: color,
      );
    }
  }
}
