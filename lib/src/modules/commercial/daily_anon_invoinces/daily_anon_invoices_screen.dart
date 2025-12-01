import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_anon_invoinces/web/daily_invoices_screen_web.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

import 'cubit/read_daily_anon_invoices_cubit.dart';

class DailyAnonInvoicesScreen extends StatelessWidget {
  const DailyAnonInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    return BlocProvider(
      create: (context) =>
          ReadDailyAnonInvoicesCubit(
            invoicesRepository: invoiceRepo,
          )..loadDailyPaidAnonInvoices(
            startDate: DateTimeTool.getTodayMidnight(),
          ),
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
        if (scrollOffset >= maxScrollExtent * 0.65) {
          context.read<ReadDailyAnonInvoicesCubit>().nextPage();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Facturas Diarias")),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const DailyAnonInvoicesScreenWeb();
  }
}
