import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/daily_client_invoices/read_daily_client_invoices_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_client_invoices/web/daily_client_invoices_screen_web.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';

class DailyClientInvoicesScreen extends StatelessWidget {
  const DailyClientInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    return BlocProvider(
      create: (context) => ReadDailyClientInvoicesCubit(
        invoicesRepository: invoiceRepo,
        defaultCreatorId: isSellerRole ? userInDb?.id : null,
      )..loadPaidInvoices(getIt<AuthCubit>().currentBranchId),
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
          context.read<ReadDailyClientInvoicesCubit>().nextPage(getIt<AuthCubit>().currentBranchId);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Ventas Por Factura")),
        body: const _Body(),
      ),
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
