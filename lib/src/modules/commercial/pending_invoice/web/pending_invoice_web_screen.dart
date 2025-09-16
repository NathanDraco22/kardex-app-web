import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/receipt_creator/receipt_creator_screen.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/custom_autocomplete_textfield.dart';

import 'mediator.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class PendingInvoiceWebScreen extends StatefulWidget {
  const PendingInvoiceWebScreen({super.key});

  @override
  State<PendingInvoiceWebScreen> createState() => _PendingInvoiceWebScreenState();
}

class _PendingInvoiceWebScreenState extends State<PendingInvoiceWebScreen> {
  final viewController = ViewController();
  @override
  Widget build(BuildContext context) {
    return PendingInvoiceMediator(
      notifier: viewController,
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      floatingActionButton: _PendingInvoiceFloatingButtons(),
      body: _Body(),
      bottomNavigationBar: _BottomPendingInvoice(),
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
      mainAxisAlignment: MainAxisAlignment.center,
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
          if (state is ReadInvoiceSuccess) {
            total = state.invoices.fold(0, (int previousValue, invoice) {
              total += invoice.total;
              return total;
            });
          }

          final totalFormatted = NumberFormatter.convertToMoneyLike(total);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Total:",
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
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
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
