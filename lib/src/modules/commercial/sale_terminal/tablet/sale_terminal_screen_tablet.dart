import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/read_terminal_product_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/payment_action.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/sale_completion.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_product_tile.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/buttons/ctrl_key_tip.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

import 'mediator.dart';

part 'sections/header_section.dart';
part 'sections/products_section.dart';
part 'sections/cart_section.dart';

class SaleTerminalScreenTablet extends StatelessWidget {
  const SaleTerminalScreenTablet({
    super.key,
    required this.viewController,
  });

  final SaleTerminalViewController viewController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteTerminalInvoiceCubit, WriteTerminalInvoiceState>(
      listener: (context, state) async {
        if (state is WriteTerminalInvoiceInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
          return;
        }

        if (state is WriteTerminalInvoiceError) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showErrorDialog(context, state.message);
          if (!context.mounted) return;
          viewController.requestSearchFocus();
          return;
        }

        if (state is WriteTerminalInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await handleTerminalSaleCompletion(context, state.invoice);
          if (!context.mounted) return;
          viewController.requestSearchFocus();
          return;
        }
      },
      child: SaleTerminalTabletMediator(
        viewController: viewController,
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final viewController = SaleTerminalTabletMediator.of(context).viewController;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (viewController.items.isNotEmpty) {
          final res = await DialogManager.confirmActionDialog(
            context,
            "¿Deseas salir de la terminal sin guardar?",
          );
          if (res != true) return;
        }
        if (!context.mounted) return;
        context.pop();
      },
      child: Scaffold(
        onEndDrawerChanged: (isOpen) {
          if (isOpen) {
            FocusManager.instance.primaryFocus?.unfocus();
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          } else {
            viewController.requestSearchFocus();
          }
        },
        appBar: AppBar(
          leading: BackButton(
            onPressed: () async {
              if (viewController.items.isNotEmpty) {
                final res = await DialogManager.confirmActionDialog(
                  context,
                  "¿Deseas salir de la terminal sin guardar?",
                );
                if (res != true) return;
              }
              if (!context.mounted) return;
              context.pop();
            },
          ),
          title: const Text("Terminal de Venta"),
          actions: [
            Builder(
              builder: (scaffoldContext) {
                return ListenableBuilder(
                  listenable: viewController,
                  builder: (context, _) {
                    final count = viewController.totalQuantity;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      offset: const Offset(-4, 4),
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        tooltip: "Ver Carrito",
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          Scaffold.of(scaffoldContext).openEndDrawer();
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        endDrawer: const Drawer(
          width: 440,
          child: _TabletCartSection(),
        ),
        floatingActionButton: Builder(
          builder: (scaffoldContext) {
            return ListenableBuilder(
              listenable: viewController,
              builder: (context, _) {
                if (viewController.items.isEmpty) return const SizedBox.shrink();
                final totalQty = viewController.totalQuantity;
                final totalAmount = NumberFormatter.convertToMoneyLike(viewController.totalAmount);
                return FloatingActionButton.extended(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    Scaffold.of(scaffoldContext).openEndDrawer();
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(
                    "$totalQty items • $totalAmount",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                );
              },
            );
          },
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const TextFieldTapRegion(
      child: Padding(
        padding: EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: _TabletHeaderSection(),
            ),
            SizedBox(height: 6),
            Expanded(
              child: _TabletProductsSection(),
            ),
          ],
        ),
      ),
    );
  }
}
