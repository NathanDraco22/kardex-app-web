import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/repositories/order_repository.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/write_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/modals/cancel_order_invoice_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/modals/confirm_order_invoice_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';
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

class InvoiceCreateMediator extends InheritedWidget {
  const InvoiceCreateMediator({super.key, required super.child, required this.order});

  final OrderInDb order;

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
      order: order,
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
    final order = InvoiceCreateMediator.of(context).order;
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

        if (state is WriteOrderToInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          String message = "Proforma convertida a factura con éxito";
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
        appBar: AppBar(title: const Text("Facturar Orden")),
        body: const _Body(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(
          builder: (context) {
            if (order.status == OrderStatus.open) {
              return const SizedBox.shrink();
            }

            if (order.invoiceId.isEmpty) {
              return const SizedBox.shrink();
            }

            return ElevatedButton.icon(
              onPressed: () {
                showInvoiceViewerDialogFromId(context, order.invoiceId);
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
              if (order.status != OrderStatus.draft) {
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
                      final res = await showCancelOrderInvoiceModal(context, order);
                      if (res != true) return;
                      writeCubit.deleteOrderDraft(order.id);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Borrar Proforma"),
                  ),
                  const SizedBox(width: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade300,
                    ),
                    onPressed: () async {
                      final res = await showConfirmOrderInvoiceModal(context, order);
                      if (res != true) return;
                      writeCubit.convertOrderToInvoice(order.id);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Facturar Proforma"),
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

  @override
  Widget build(BuildContext context) {
    final mediator = InvoiceCreateMediator.of(context);
    final order = mediator.order;
    final saleItems = order.saleItems;
    final totalFormatted = NumberFormatter.convertToMoneyLike(order.total);
    return Center(
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

                      Text(
                        "Total: $totalFormatted",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                        const Text(
                          "Detalle:",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.start,
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
