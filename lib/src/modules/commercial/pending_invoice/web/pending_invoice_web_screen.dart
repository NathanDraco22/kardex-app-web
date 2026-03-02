import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/modals/invoice_receipts_history_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/receipt_creator_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/invoice_devolution_tile.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/map/launch_map_button.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/write_receipt_cubit.dart';

import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/fast_receipt_logic.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/modals/fast_payment_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/credit_session_history_dialog.dart';

import 'mediator.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class PendingInvoiceWebScreen extends StatefulWidget {
  const PendingInvoiceWebScreen({super.key, required this.client});

  final ClientInDb client;

  @override
  State<PendingInvoiceWebScreen> createState() => _PendingInvoiceWebScreenState();
}

class _PendingInvoiceWebScreenState extends State<PendingInvoiceWebScreen> {
  final viewController = ViewController();

  @override
  void initState() {
    viewController.changeClient(widget.client);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceREpo = context.read<InvoicesRepository>();
    final devolutionRepo = context.read<DevolutionsRepository>();
    final receiptRepo = context.read<ReceiptsRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadPendingInvoiceCubit(
            invoicesRepository: invoiceREpo,
            devolutionsRepository: devolutionRepo,
          ),
        ),
        BlocProvider(
          create: (context) => WriteReceiptCubit(
            receiptsRepository: receiptRepo,
          ),
        ),
      ],
      child: PendingInvoiceMediator(
        notifier: viewController,
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold();

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  bool hasInitLoading = false;

  @override
  Widget build(BuildContext context) {
    final selectedClient = PendingInvoiceMediator.of(context).notifier?.selectedClient;
    if (selectedClient != null && !hasInitLoading) {
      context.read<ReadPendingInvoiceCubit>().loadPaginatedInvoices(
        selectedClient.id,
      );
      hasInitLoading = true;
    }
    return BlocListener<WriteReceiptCubit, WriteReceiptState>(
      listener: (context, state) async {
        if (state is WriteReceiptInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteReceiptError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }
        if (state is WriteReceiptSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);

          await DialogManager.showInfoDialog(context, "Abono Rápido creado con éxito");
          if (!context.mounted) return;
          await showReceiptViewerDialog(context, state.receipt);
          if (!context.mounted) return;

          final selectedClient = PendingInvoiceMediator.of(context).notifier?.selectedClient;
          if (selectedClient != null) {
            context.read<ReadPendingInvoiceCubit>().loadPaginatedInvoices(selectedClient.id);
          }
        }
      },
      child: Scaffold(
        floatingActionButton: const _PendingInvoiceFloatingButtons(),
        appBar: AppBar(title: const Text("Facturas por Cobrar de Cliente")),
        body: const _Body(),
        bottomNavigationBar: const _BottomPendingInvoice(),
      ),
    );
  }
}

class _PendingInvoiceFloatingButtons extends StatelessWidget {
  const _PendingInvoiceFloatingButtons();

  @override
  Widget build(BuildContext context) {
    final viewController = PendingInvoiceMediator.of(context).notifier!;
    if (viewController.selectedInvoices.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            viewController.clearSelected();
          },
          child: const Icon(Icons.clear),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptCreatorScreen(
                  client: viewController.selectedClient!,
                  invoices: viewController.selectedInvoices,
                  devolutions: viewController.selectedDevolutions,
                ),
              ),
            );
          },
          child: const Icon(Icons.check),
        ),
      ],
    );
  }
}

class _BottomPendingInvoice extends StatelessWidget {
  const _BottomPendingInvoice();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadPendingInvoiceCubit>();
    final state = readCubit.state;
    return BottomAppBar(
      height: 60,
      child: Builder(
        builder: (context) {
          int total = 0;
          int totalDevolutions = 0;
          if (state is ReadInvoiceSuccess) {
            total = state.invoices.fold(0, (int previousValue, invoice) {
              total += invoice.totalRemaining;
              return total;
            });

            totalDevolutions = state.devolutions.fold(0, (int previousValue, devolution) {
              totalDevolutions += devolution.total;
              return totalDevolutions;
            });
          }

          final totalFormatted = NumberFormatter.convertToMoneyLike(total);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Total: ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalFormatted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(width: 24),
            ],
          );
        },
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
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: _HeaderSection(),
            ),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
