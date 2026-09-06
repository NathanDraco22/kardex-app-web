import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/user_reports/read_user_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/user_operations_results/desktop/user_operations_results_desktop.dart';
import 'package:kardex_app_front/src/modules/commercial/user_operations_results/mobile/user_operations_results_mobile.dart';
import 'package:kardex_app_front/src/modules/commercial/user_operations_results/tablet/user_operations_results_tablet.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';

class UserOperationsResultsScreen extends StatelessWidget {
  const UserOperationsResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRepo = context.read<ReportsRepository>();
    final authCubit = getIt<AuthCubit>();
    final currentUser = authCubit.user;

    return BlocProvider(
      create: (context) => ReadUserReportsCubit(
        reportsRepository: reportsRepo,
        initialUser: currentUser,
      )..loadReports(authCubit.currentBranchId),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arqueo y Resultados por Usuario")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop()) {
      return const UserOperationsResultsDesktop();
    }

    if (context.isTablet()) {
      return const UserOperationsResultsTablet();
    }

    return const UserOperationsResultsMobile();
  }
}
