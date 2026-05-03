import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/cubit/write_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/mobile/client_invoices_screen_mobile.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/view_controller.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/web/client_invoices_screen_web.dart';

class ProformaScreen extends StatefulWidget {
  const ProformaScreen({super.key});

  @override
  State<ProformaScreen> createState() => _ProformaScreenState();
}

class _ProformaScreenState extends State<ProformaScreen> {
  final viewController = ClientInvoiceViewController();
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
            documentType: CommercialDocumentType.quote,
            viewController: viewController,
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

    if (isMobile) {
      return const ClientInvoicesScreenMobile(
        pageTitle: "Proforma / Cotización",
        actionButtonLabel: "Finalizar Cotización",
      );
    }

    return const ClientInvoicesScreenWeb(
      pageTitle: "Proforma / Cotización",
      actionButtonLabel: "Finalizar Cotización",
    );
  }
}
