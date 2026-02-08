import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'cubit/write_invoice_cubit.dart';
import 'mobile/client_invoices_screen_mobile.dart';
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
            documentType: isOrder ? CommercialDocumentType.order : CommercialDocumentType.invoice,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final res = await DialogManager.confirmActionDialog(context, "Deseas salir?");
        if (res != true) return;
        if (!context.mounted) return;
        context.pop();
      },
      child: const Scaffold(
        body: _Body(),
      ),
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
