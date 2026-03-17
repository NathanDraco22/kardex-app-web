import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';

import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';

import 'package:kardex_app_front/src/tools/session_tool.dart';

import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/client_selector_card.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import '../widgets/client_invoice_table.dart';
import '../widgets/dialogs/confirm_invoice_dialog.dart';
import '../cubit/write_invoice_cubit.dart';
import 'mediator.dart';

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
  ViewController viewController = ViewController();
  ClientInvoiceTableController tableController = ClientInvoiceTableController();

  @override
  Widget build(BuildContext context) {
    if (rebuild) {
      rebuild = false;
      viewController = ViewController();
      tableController = ClientInvoiceTableController();
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
        tableController: tableController,
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final controller = ClientInvoiceWebMediator.of(context).tableController;
    final cubit = context.read<WriteInvoiceCubit>();
    final webScreenWidget = context.findAncestorWidgetOfExactType<ClientInvoicesScreenWeb>();

    String title = webScreenWidget?.pageTitle ?? "Facturacion a Clientes";
    if (webScreenWidget?.pageTitle == null && cubit.isOrder) title = "Orden de compra";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                    final totalMoney = NumberFormatter.convertToMoneyLike(controller.total);
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        totalMoney,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        padding: EdgeInsets.all(8.0),
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
