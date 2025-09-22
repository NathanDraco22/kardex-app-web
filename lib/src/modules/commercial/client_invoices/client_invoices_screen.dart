import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/mobile/client_invoices_screen_mobile.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'web/client_invoices_screen_web.dart';

class ClientInvoiceScreen extends StatelessWidget {
  const ClientInvoiceScreen({super.key, this.isOrder = false});

  final bool isOrder;

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    final orderRepo = context.read<OrdersRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WriteInvoiceCubit(
            invoicesRepository: invoiceRepo,
            ordersRepository: orderRepo,
            isOrder: isOrder,
          ),
        ),
      ],
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

    if (isMobile) return const ClientInvoicesScreenMobile();

    return const ClientInvoicesScreenWeb();
  }
}
