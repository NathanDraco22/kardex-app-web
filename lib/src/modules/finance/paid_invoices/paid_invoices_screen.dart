import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

import 'cubit/read_paid_invoices_cubit.dart';

import 'mobile/paid_invoices_mobile_screen.dart';
import 'web/paid_invoices_web_screen.dart';

class PaidInvoicesScreen extends StatelessWidget {
  const PaidInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    return BlocProvider(
      create: (context) => ReadPaidInvoicesCubit(
        invoicesRepository: invoiceRepo,
      )..loadPaidInvoices(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final scrollOffset = notification.metrics.pixels;
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        if (scrollOffset >= maxScrollExtent * 0.7) {
          context.read<ReadPaidInvoicesCubit>().nextPage();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Facturas Liquidadas")),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile();

    if (isMobile) return const PaidInvoicesMobileScreen();
    return const PaidInvoicesWebScreen();
  }
}
