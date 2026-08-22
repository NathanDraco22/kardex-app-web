import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/src/modules/finance/daily_operations_results/desktop/daily_operations_results_desktop.dart';
import 'package:kardex_app_front/src/modules/finance/daily_operations_results/mobile/daily_operations_results_mobile.dart';
import 'package:kardex_app_front/src/modules/finance/daily_operations_results/tablet/daily_operations_results_tablet.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';

class DailyOperationsResultsScreen extends StatelessWidget {
  const DailyOperationsResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRepo = context.read<ReportsRepository>();
    return BlocProvider(
      create: (context) => ReadReportsCubit(
        reportsRepository: reportsRepo,
      )..loadReports(getIt<AuthCubit>().currentBranchId),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resultado de Operaciones Diarias")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop()) {
      return const DailyOperationsResultsDesktop();
    }

    if (context.isTablet()) {
      return const DailyOperationsResultsTablet();
    }

    return const DailyOperationsResultsMobile();
  }
}
