import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_business/kardex_business.dart';
import 'cubit/read_devolutions_cubit.dart';

import 'web/devolutions_screen_web.dart';

class DevolutionsScreen extends StatelessWidget {
  const DevolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    return BlocProvider(
      create: (context) => ReadDevolutionsCubit(
        invoicesRepository: invoiceRepo,
        defaultCreatorId: isSellerRole ? userInDb?.id : null,
      )..loadDailyInvoices(getIt<AuthCubit>().currentBranchId),
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
          context.read<ReadDevolutionsCubit>().nextPage(getIt<AuthCubit>().currentBranchId);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Devoluciones")),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const DevolutionsScreenWeb();
  }
}
