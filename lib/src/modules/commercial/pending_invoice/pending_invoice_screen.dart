import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/web/pending_invoice_web_screen.dart';

class PendingInvoiceScreen extends StatelessWidget {
  const PendingInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    return BlocProvider(
      create: (context) => ReadPendingInvoiceCubit(
        invoicesRepository: invoiceRepo,
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
        title: const Text("Facturas por cobrar"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const PendingInvoiceWebScreen();
  }
}
