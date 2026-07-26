import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/write_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/modals/cancel_order_invoice_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/modals/confirm_order_invoice_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/tools/printers/order_printer.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/single_order_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/search_product_commercial_dialog.dart';
import 'package:kardex_app_front/widgets/row_widgets/sale_item_row.dart';

Future<OrderInDb?> showProformaInvoiceCreatorDialog(BuildContext context, OrderInDb order) async {
  final readCubit = context.read<ReadProformaCubit>();
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
    final authCubit = getIt<AuthCubit>();
    final authState = authCubit.state;
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(
          child: Text("Error"),
        ),
      );
    }
    final orderContainer = InvoiceCreateMediator.of(context).orderContainer;
    final writeCubit = context.read<WriteOrderCubit>();

    return BlocListener<WriteOrderCubit, WriteOrderState>(
      listener: (context, state) async {
        if (state is WriteOrderInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteOrderSuccess) {
          orderContainer.updateOrder(state.order);
          if (!context.mounted) return;
          final readCubit = context.read<ReadProformaCubit>();
          await readCubit.updateOrderCache(state.order);
          return;
        }

        if (state is WriteOrderError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteOrderToInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          String message = "Cotización convertida a factura con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          final readCubit = context.read<ReadProformaCubit>();
          await readCubit.deleteOrderDraft(state.order.id);

          if (!context.mounted) return;
          await showInvoiceViewerDialog(context, state.invoice);
          if (!context.mounted) return;
          Navigator.pop(context, state.order);
        }

        if (state is WriteOrderDraftDeleted) {
          LoadingDialogManager.closeLoadingDialog(context);
          String message = "Proforma borrada con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          final readCubit = context.read<ReadProformaCubit>();
          await readCubit.deleteOrderDraft(state.order.id);
          if (!context.mounted) return;
          Navigator.pop(context, state.order);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Facturar Orden"),
          actions: [
            IconButton(
              tooltip: "Exportar PDF (A4)",
              onPressed: () async {
                final template = SingleOrderTemplate(order: orderContainer.order, branch: authState.branch);
                await PdfExportTool.export(template, fileName: "cotizacion_${orderContainer.order.docNumber}.pdf");
              },
              icon: const Icon(Icons.picture_as_pdf),
            ),
            IconButton(
              tooltip: "Compartir Cotización",
              onPressed: () async {
                final paperSize = await PrintManager.getLocalPaperSize();
                shareOrder(orderContainer.order, authState.branch, paperSize: paperSize);
              },
              icon: const Icon(Icons.share),
            ),
            IconButton(
              tooltip: "Imprimir Cotización",
              onPressed: () async {
                final paperSize = await PrintManager.getLocalPaperSize();
                printOrder(orderContainer.order, authState.branch, paperSize: paperSize);
              },
              icon: const Icon(Icons.print),
            ),
          ],
        ),
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
              if (orderContainer.order.status != OrderStatus.draft) {
                return const SizedBox.shrink();
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
                      writeCubit.deleteOrderDraft(orderContainer.order.id);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar"),
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
                    label: const Text("Facturar"),
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

    return BlocListener<WriteOrderCubit, WriteOrderState>(
      listener: (context, state) {
        if (state is WriteOrderSuccess) {
          setState(() {
            _currentOrder = state.order;
            _isAscending = null; // Reset order visual al actualizar externamente
          });
          LoadingDialogManager.closeLoadingDialog(context);
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
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
                              "#${order.docNumber}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  DateTimeTool.formatddMMyyEs(order.createdAt),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  DateTimeTool.formatHHmm(order.createdAt),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.createdBy.name,
                            ),
                          ],
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
                              SizedBox(
                                width: 80,
                                child: IconButton(
                                  tooltip: _isAscending == null
                                      ? "Ordenar productos (A-Z)"
                                      : _isAscending!
                                      ? "Ordenar Z-A"
                                      : "Ordenar A-Z",
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.sort_by_alpha, size: 28),
                                      if (_isAscending != null)
                                        Icon(
                                          _isAscending! ? Icons.arrow_downward : Icons.arrow_upward,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                  onPressed: _toggleSort,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                const Divider(),
                                ..._buildSaleItemRows(context, saleItems),
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
      ),
    );
  }

  Iterable<Widget> _buildSaleItemRows(
    BuildContext context,
    List<SaleItem> saleItems,
  ) sync* {
    for (var i = 0; i < saleItems.length; i++) {
      final saleItem = saleItems[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;

      yield SaleItemRow(
        onEdit: () async {
          CommercialProductResult? commercial;
          if (context.isMobile()) {
            commercial = await showCommercialProductModalFromId(
              context,
              productId: saleItem.product.id,
              previousSaleItem: saleItem,
              restrictStock: false,
            );
          } else {
            commercial = await showCommercialProductDialogFromId(
              context,
              productId: saleItem.product.id,
              previousSaleItem: saleItem,
              restrictStock: false,
            );
          }

          if (commercial == null) return;

          if (!context.mounted) return;

          if (_currentOrder == null) return;

          final newItem = SaleItem(
            product: ProductItem.fromJson({
              ...saleItem.product.toJson(),
              'unitName': commercial.selectedUnitName.isNotEmpty
                  ? commercial.selectedUnitName
                  : saleItem.product.unitName,
            }),
            selectedPrice: commercial.selectedPriceLevel,
            cost: commercial.product.account.averageCost,
            price: commercial.newPrice,
            quantity: commercial.quantity * commercial.conversionFactor,
            discountPercentage: commercial.discountPercent,
            totalDiscount: commercial.totalDiscount,
            subTotal: commercial.subTotal,
            total: commercial.total,
            conversionFactor: commercial.conversionFactor,
          );

          List<SaleItem> newItems = List.from(saleItems);
          newItems[i] = newItem;

          int newTotal = 0;
          int newTotalCost = 0;

          for (var item in newItems) {
            newTotal += item.total;
            newTotalCost += (item.cost * item.quantity);
          }

          final updateOrder = UpdateOrder(
            saleItems: newItems,
            total: newTotal,
            totalCost: newTotalCost,
          );

          context.read<WriteOrderCubit>().updateOrder(_currentOrder!.id, updateOrder);
        },

        onRemove: () async {
          final res = await DialogManager.confirmActionDialog(context, "Eliminar ${saleItem.product.name}");
          if (res != true) return;

          if (!context.mounted) return;

          if (_currentOrder == null) return;

          List<SaleItem> newItems = List.from(saleItems);
          newItems.removeAt(i);

          int newTotal = 0;
          int newTotalCost = 0;

          for (var item in newItems) {
            newTotal += item.total;
            newTotalCost += (item.cost * item.quantity);
          }

          final updateOrder = UpdateOrder(
            saleItems: newItems,
            total: newTotal,
            totalCost: newTotalCost,
          );

          context.read<WriteOrderCubit>().updateOrder(
            _currentOrder!.id,
            updateOrder,
          );
        },
        saleItem: saleItem,
        color: color,
      );
    }

    yield const Divider();
    yield Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Agregar producto"),
          onPressed: () async {
            CommercialProductResult? commercial;
            if (context.isMobile()) {
              commercial = await showCommercialProductSearchDelegate(
                context,
                restrictStock: false,
              );
            } else {
              commercial = await showSearchProductCommercialDialog(
                context,
                restrictStock: false,
              );
            }

            if (commercial == null) return;

            if (!context.mounted) return;

            if (_currentOrder == null) return;

            List<SaleItem> newItems = List.from(saleItems);
            newItems.add(
              SaleItem(
                product: ProductItem.fromJson({
                  ...commercial.product.toJson(),
                  'unitName': commercial.selectedUnitName.isNotEmpty
                      ? commercial.selectedUnitName
                      : commercial.product.unitName,
                }),
                selectedPrice: commercial.selectedPriceLevel,
                cost: commercial.product.account.averageCost,
                price: commercial.newPrice,
                quantity: commercial.quantity * commercial.conversionFactor,
                discountPercentage: commercial.discountPercent,
                totalDiscount: commercial.totalDiscount,
                subTotal: commercial.subTotal,
                total: commercial.total,
                conversionFactor: commercial.conversionFactor,
              ),
            );

            int newTotal = 0;
            int newTotalCost = 0;

            for (var item in newItems) {
              newTotal += item.total;
              newTotalCost += (item.cost * item.quantity);
            }

            final updateOrder = UpdateOrder(
              saleItems: newItems,
              total: newTotal,
              totalCost: newTotalCost,
            );

            context.read<WriteOrderCubit>().updateOrder(
              _currentOrder!.id,
              updateOrder,
            );
          },
        ),
      ],
    );
  }
}
