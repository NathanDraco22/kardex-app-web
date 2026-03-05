import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/domain/models/common/client_info.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/cubits/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/web/widgets/anon_invoice_table.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/widgets/dialogs/payment_confirmation_dialog.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/global_stock_search_modal.dart';
import 'package:kardex_app_front/widgets/empty_scaffold.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

import 'mediator.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class AnonInvoicesScreenWeb extends StatefulWidget {
  const AnonInvoicesScreenWeb({super.key});

  @override
  State<AnonInvoicesScreenWeb> createState() => _AnonInvoicesScreenWebState();
}

class _AnonInvoicesScreenWebState extends State<AnonInvoicesScreenWeb> {
  bool rebuild = false;
  AnonInvoiceTableController tableController = AnonInvoiceTableController();
  AnonInvoiceViewController viewController = AnonInvoiceViewController();

  @override
  Widget build(BuildContext context) {
    if (rebuild) {
      rebuild = false;
      tableController = AnonInvoiceTableController();
      Future(() => setState(() {}));
      return const EmptyScaffold();
    }

    return BlocListener<WriteAnonInvoiceCubit, WriteAnonInvoiceState>(
      listener: (context, state) async {
        if (state is WriteAnonInvoiceInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteAnonInvoiceError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteAnonInvoiceSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          String message = "Factura guardada con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          rebuild = true;
          setState(() {});
        }
      },
      child: AnonInvoiceWebMediator(
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
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyG,
          control: true,
        ): () =>
            saveAnonInvoiceAction(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () async {
                if (AnonInvoiceWebMediator.of(context).tableController.items.isNotEmpty) {
                  final res = await DialogManager.confirmActionDialog(context, "Deseas salir sin guardar?");
                  if (res != true) {
                    return;
                  }
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            title: const Text("Facturacion de Productos"),
          ),
          body: const _Body(),
          bottomNavigationBar: const _AnonBottomAppBar(),
        ),
      ),
    );
  }
}

class _AnonBottomAppBar extends StatelessWidget {
  const _AnonBottomAppBar();

  @override
  Widget build(BuildContext context) {
    final viewController = AnonInvoiceWebMediator.of(context).viewController;
    final tableController = AnonInvoiceWebMediator.of(context).tableController;

    return BottomAppBar(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListenableBuilder(
          listenable: Listenable.merge([viewController, tableController]),
          builder: (context, _) {
            final total = tableController.total;
            final formattedTotal = NumberFormatter.convertToMoneyLike(total);
            return Row(
              children: [
                const Spacer(
                  flex: 4,
                ),
                Expanded(
                  child: Row(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedTotal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
              height: 160,
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
