import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/read_terminal_product_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/payment_action.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/sale_completion.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/shared_actions.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_cart_item_tile.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/terminal_product_tile.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/buttons/ctrl_key_tip.dart';
import 'package:kardex_app_front/widgets/client_selector_card.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

import 'mediator.dart';

part 'sections/header_section.dart';
part 'sections/products_section.dart';
part 'sections/cart_section.dart';

class SaleTerminalScreenWeb extends StatelessWidget {
  const SaleTerminalScreenWeb({
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
      child: SaleTerminalWebMediator(
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
    final viewController = SaleTerminalWebMediator.of(context).viewController;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handleTerminalExit(context, viewController: viewController);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => handleTerminalExit(context, viewController: viewController),
          ),
          title: const Text("Terminal de Venta"),
          actions: [
            IconButton(
              icon: Icon(Icons.pause_circle_outline, color: Colors.amber.shade800),
              tooltip: "Ventas en espera",
              onPressed: () => openHoldSalesModal(context, viewController: viewController),
            ),
            const SizedBox(width: 8),
          ],
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
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 240,
                      child: _HeaderSection(),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: _ProductsSection(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 35,
                child: _CartSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
