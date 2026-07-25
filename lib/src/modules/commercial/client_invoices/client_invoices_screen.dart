import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'cubit/write_invoice_cubit.dart';
import 'mobile/client_invoices_screen_mobile.dart';
import 'web/client_invoices_screen_web.dart';

import 'view_controller.dart';

class ClientInvoiceScreen extends StatefulWidget {
  const ClientInvoiceScreen({
    super.key,
    this.isOrder = false,
    this.isWholesale = false,
  });

  final bool isOrder;
  final bool isWholesale;

  @override
  State<ClientInvoiceScreen> createState() => _ClientInvoiceScreenState();
}

class _ClientInvoiceScreenState extends State<ClientInvoiceScreen> {
  late final ClientInvoiceViewController viewController;

  @override
  void initState() {
    super.initState();
    viewController = ClientInvoiceViewController(isWholesale: widget.isWholesale);
  }

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
            documentType: widget.isOrder ? .order : .invoice,
            viewController: viewController,
          ),
        ),
      ],
      child: _RootScaffold(isWholesale: widget.isWholesale),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({required this.isWholesale});
  final bool isWholesale;

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
      child: ShortcutContainer(
        child: Scaffold(
          body: _Body(isWholesale: isWholesale),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.isWholesale});
  final bool isWholesale;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile();

    if (isMobile) {
      return ClientInvoicesScreenMobile(
        pageTitle: isWholesale ? "Facturacion Cliente (Mayorista)" : null,
      );
    }

    return ClientInvoicesScreenWeb(
      pageTitle: isWholesale ? "Facturacion Cliente (Mayorista)" : null,
    );
  }
}
