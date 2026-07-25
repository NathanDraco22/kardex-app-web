import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

import 'package:kardex_app_front/widgets/client_selector_card.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import '../view_controller.dart';
import '../widgets/client_invoice_table.dart';
import '../widgets/dialogs/confirm_invoice_dialog.dart';
import '../widgets/dialogs/payment_confirmation_dialog.dart';
import '../cubit/write_invoice_cubit.dart';
import 'mediator.dart';
import 'package:toastification/toastification.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class ClientInvoicesScreenWeb extends StatefulWidget {
  const ClientInvoicesScreenWeb({
    super.key,
    this.pageTitle,
    this.actionButtonLabel,
  });

  final String? pageTitle;
  final String? actionButtonLabel;

  @override
  State<ClientInvoicesScreenWeb> createState() => _ClientInvoicesScreenWebState();
}

class _ClientInvoicesScreenWebState extends State<ClientInvoicesScreenWeb> {
  bool rebuild = false;

  late ClientInvoiceViewController viewController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewController = context.read<WriteInvoiceCubit>().viewController;
    viewController.updatePricesOnClientChange = true;
    viewController.onPricesChanged = () {
      if (!mounted) return;
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        title: const Text('Se han cambiado los precios'),
        description: const Text('Los precios se actualizaron según el nivel del cliente.'),
        autoCloseDuration: const Duration(seconds: 3),
        style: ToastificationStyle.flatColored,
      );
    };
  }

  @override
  void dispose() {
    viewController.onPricesChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (rebuild) {
      rebuild = false;
      final cubit = context.read<WriteInvoiceCubit>();
      cubit.viewController.clear();
      Future(() => setState(() {}));
      return const EmptyScaffold();
    }

    return BlocListener<WriteInvoiceCubit, WriteInvoiceState>(
      listener: (context, state) async {
        if (state is WriteInvoiceInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteInvoiceError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          final cubit = context.read<WriteInvoiceCubit>();
          String message = "Factura guardada con éxito";
          if (cubit.isOrder) message = "Orden de compra enviada con éxito";
          if (cubit.documentType == CommercialDocumentType.quote) message = "Cotización guardada con éxito";

          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          rebuild = true;
          setState(() {});
        }
      },

      child: ClientInvoiceWebMediator(
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
    final controller = ClientInvoiceWebMediator.of(context).viewController;
    final cubit = context.read<WriteInvoiceCubit>();
    final webScreenWidget = context.findAncestorWidgetOfExactType<ClientInvoicesScreenWeb>();

    String title = webScreenWidget?.pageTitle ?? "Facturacion a Clientes";
    if (webScreenWidget?.pageTitle == null && cubit.isOrder) title = "Orden de compra";

    return Scaffold(
      appBar: AppBar(
        title: title.contains("(Mayorista)")
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "${title.replaceAll("(Mayorista)", "").trim()} "),
                    const TextSpan(
                      text: "(Mayorista)",
                      style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : Text(title),
      ),
      body: const _Body(),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Spacer(
                flex: 6,
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Total:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, _) {
                    final totalMoney = NumberFormatter.convertToMoneyLike(controller.totalAmount);
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        totalMoney,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 170,
              child: _HeaderSection(),
            ),
            SizedBox(height: 8),
            Flexible(
              fit: FlexFit.tight,
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
