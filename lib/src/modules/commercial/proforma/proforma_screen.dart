import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/mobile/client_invoices_screen_mobile.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/view_controller.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/web/client_invoices_screen_web.dart';

class ProformaScreen extends StatefulWidget {
  const ProformaScreen({
    super.key,
    this.isWholesale = false,
  });

  final bool isWholesale;

  @override
  State<ProformaScreen> createState() => _ProformaScreenState();
}

class _ProformaScreenState extends State<ProformaScreen> {
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
    return ShortcutContainer(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WriteInvoiceCubit(
              invoicesRepository: invoiceRepo,
              ordersRepository: orderRepo,
              documentType: CommercialDocumentType.quote,
              viewController: viewController,
            ),
          ),
        ],
        child: _RootScaffold(isWholesale: widget.isWholesale),
      ),
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
      child: Scaffold(
        body: _Body(isWholesale: isWholesale),
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

    final pageTitleWholesale = isWholesale ? "Crear Cotización (Mayorista)" : "Proforma / Cotización";

    if (isMobile) {
      return ClientInvoicesScreenMobile(
        pageTitle: pageTitleWholesale,
        actionButtonLabel: "Enviar Cotización",
      );
    }

    return ClientInvoicesScreenWeb(
      pageTitle: pageTitleWholesale,
      actionButtonLabel: "Enviar Cotización",
    );
  }
}
