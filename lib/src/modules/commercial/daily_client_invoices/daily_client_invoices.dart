import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_client_invoices/cubit/read_daily_invoices_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_client_invoices/web/daily_client_invoices_screen_web.dart';

class DailyClientInvoices extends StatelessWidget {
  const DailyClientInvoices({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    return BlocProvider(
      create: (context) => ReadDailyInvoicesCubit(
        invoicesRepository: invoiceRepo,
      )..loadDailyPaidInvoices(),
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
        title: const Text("Registro de Facturas por Clientes"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const DailyClientInvoicesScreenWeb();
  }
}
