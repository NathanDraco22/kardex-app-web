import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'web/range_finance_report_screen_web.dart';

class FinanceRangeReportScreen extends StatelessWidget {
  const FinanceRangeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRepo = context.read<ReportsRepository>();
    return BlocProvider(
      create: (context) {
        final cubit = ReadReportsCubit(
          reportsRepository: reportsRepo,
        );
        // Inicializar rango: desde el primer día del mes actual hasta hoy
        final now = DateTime.now();
        cubit.startDate = DateTime(now.year, now.month, 1);
        cubit.endDate = DateTimeTool.getTodayMidnight();

        // Cargar los reportes de la sucursal actual
        cubit.loadReports(getIt<AuthCubit>().currentBranchId);
        return cubit;
      },
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reporte de Ventas y Flujos")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const RangeFinanceReportScreenWeb();
  }
}
