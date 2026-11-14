import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/src/core/shift_guard.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_pending_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/modals/invoice_receipts_history_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/receipt_creator_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/invoice_devolution_tile.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/credit_notes_summary_tile.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/widget/pending_invoices_statement_image_dialog.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_acredit_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
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
    final creditNoteRepo = context.read<CreditNotesRepository>();
    final compositeRepo = context.read<CompositeRepository>();
    final receiptRepo = context.read<ReceiptsRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadPendingInvoiceCubit(
            invoicesRepository: invoiceREpo,
            devolutionsRepository: devolutionRepo,
            creditNotesRepository: creditNoteRepo,
            compositeRepository: compositeRepo,
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
        getIt<AuthCubit>().currentBranchId,
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
            context.read<ReadPendingInvoiceCubit>().loadPaginatedInvoices(
              selectedClient.id,
              getIt<AuthCubit>().currentBranchId,
            );
          }
        }
      },
      child: Scaffold(
        floatingActionButton: const _PendingInvoiceFloatingButtons(),
        appBar: AppBar(
          title: const Text("Facturas por Cobrar de Cliente"),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: "Compartir estado de cuenta en imagen",
              onPressed: () {
                final state = context.read<ReadPendingInvoiceCubit>().state;
                final selectedClient = PendingInvoiceMediator.of(context).notifier?.selectedClient;
                if (selectedClient == null || state is! ReadInvoiceSuccess || state.invoices.isEmpty) {
                  DialogManager.showInfoDialog(
                    context,
                    "No hay facturas pendientes para compartir.",
                  );
                  return;
                }
                showPendingInvoicesStatementImageDialog(
                  context: context,
                  client: selectedClient,
                  invoices: state.invoices,
                  devolutions: state.devolutions,
                  creditNotes: state.creditNotes,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
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
                builder: (_) => BlocProvider.value(
                  value: context.read<ReadPendingInvoiceCubit>(),
                  child: ReceiptCreatorScreen(
                    client: viewController.selectedClient!,
                    invoices: viewController.selectedInvoices,
                    devolutions: viewController.selectedDevolutions,
                    creditNotes: viewController.selectedCreditNotes,
                  ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        int total = 0;
        int totalDevolutions = 0;
        int totalCreditNotes = 0;
        if (state is ReadInvoiceSuccess) {
          if (state.summary != null) {
            total = state.summary!.totalInvoices;
            totalDevolutions = state.summary!.totalDevolutions;
            totalCreditNotes = state.summary!.totalCreditNotes;
          } else {
            total = state.invoices.fold(0, (int previousValue, invoice) {
              total += invoice.totalRemaining;
              return total;
            });

            totalDevolutions = state.devolutions.fold(0, (int previousValue, devolution) {
              totalDevolutions += devolution.total;
              return totalDevolutions;
            });

            totalCreditNotes = state.creditNotes.fold(0, (int previousValue, cn) {
              totalCreditNotes += cn.total;
              return totalCreditNotes;
            });
          }
        }

        final netTotal = (total - totalDevolutions - totalCreditNotes) > 0
            ? (total - totalDevolutions - totalCreditNotes)
            : 0;

        final totalFormatted = NumberFormatter.convertToMoneyLike(total);
        final netTotalFormatted = NumberFormatter.convertToMoneyLike(netTotal);
        final hasDiscounts = totalCreditNotes > 0 || totalDevolutions > 0;

        // Disposición responsiva para teléfonos móviles
        if (isMobile && hasDiscounts) {
          return BottomAppBar(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fila Superior: Subtotales y Descuentos en pastillas compactas
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Facturas: $totalFormatted",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (totalCreditNotes > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF9FE),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE9D8FD), width: 0.8),
                          ),
                          child: Text(
                            "NC: -${NumberFormatter.convertToMoneyLike(totalCreditNotes)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                      if (totalDevolutions > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade200, width: 0.8),
                          ),
                          child: Text(
                            "Dev: -${NumberFormatter.convertToMoneyLike(totalDevolutions)}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 3),

                // Fila Inferior: Neto por Cobrar destacado
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Neto por Cobrar: ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        netTotalFormatted,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Modo Desktop o pantalla sin descuentos
        return BottomAppBar(
          height: 60,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasDiscounts) ...[
                  Text(
                    "Facturas: $totalFormatted",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (totalCreditNotes > 0) ...[
                    const SizedBox(width: 16),
                    Text(
                      "Notas Crédito: -${NumberFormatter.convertToMoneyLike(totalCreditNotes)}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                  if (totalDevolutions > 0) ...[
                    const SizedBox(width: 16),
                    Text(
                      "Devoluciones: -${NumberFormatter.convertToMoneyLike(totalDevolutions)}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                  const SizedBox(width: 20),
                  const Text(
                    "Neto por Cobrar: ",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    netTotalFormatted,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ] else ...[
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
                  ),
                ],
                const SizedBox(width: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: const SingleChildScrollView(
                child: _HeaderSection(),
              ),
            ),
            const Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
