import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/invoice_repository.dart';
import 'package:kardex_app_front/src/modules/commercial/anon_invoices/cubits/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

import 'web/anon_invoices_screen_web.dart';
import 'mobile/anon_invoices_screen_mobile.dart';

class AnonInvoicesScreen extends StatelessWidget {
  const AnonInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    return BlocProvider(
      create: (context) => WriteAnonInvoiceCubit(
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
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile();

    if (isMobile) return const AnonInvoicesScreenMobile();

    return const AnonInvoicesScreenWeb();
  }
}
