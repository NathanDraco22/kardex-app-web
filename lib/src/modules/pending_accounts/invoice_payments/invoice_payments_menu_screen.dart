import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/client_selector_card.dart';
import 'package:kardex_app_front/widgets/custom_invoice_list_tile.dart';

import 'cubit/read_invoice_payments_cubit.dart';
import 'invoice_payments_detail_screen.dart';

class InvoicePaymentsMenuScreen extends StatelessWidget {
  const InvoicePaymentsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadInvoicePaymentsCubit(
        invoicesRepository: context.read<InvoicesRepository>(),
      ),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonos por Factura"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoicePaymentsCubit>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 170,
              child: ClientSelectorCard(
                onChange: (client) {
                  readCubit.loadInvoices(client?.id, getIt<AuthCubit>().currentBranchId);
                },
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

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoicePaymentsCubit>();
    final state = readCubit.state;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        final scrollOffset = notification.metrics.pixels;
        final nextPageThreshold = maxScrollExtent * 0.7;

        if (scrollOffset >= nextPageThreshold) {
          readCubit.nextPage(getIt<AuthCubit>().currentBranchId);
        }
        return false;
      },
      child: Card(
        child: Column(
          children: [
            Builder(
              builder: (context) {
                if (state is ReadInvoicePaymentsLoading || state is ReadInvoicePaymentsSearching) {
                  return const LinearProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: _buildContent(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReadInvoicePaymentsState state) {
    if (state is ReadInvoicePaymentsInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "Selecciona un cliente para ver sus facturas",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state is ReadInvoicePaymentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReadInvoicePaymentsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    state as ReadInvoicePaymentsSuccess;

    if (state.invoices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "No hay facturas para este cliente",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: state.invoices.length,
      separatorBuilder: (context, index) => const Divider(height: 0.0),
      itemBuilder: (context, index) {
        final invoice = state.invoices[index];
        final tileColor = index.isOdd ? Colors.grey.shade200 : Colors.white;

        return CustomInvoiceListTile(
          invoice: invoice,
          backgroundColor: tileColor,
          onTap: () {
            showInvoicePaymentsDetailScreen(context, invoice);
          },
        );
      },
    );
  }
}
