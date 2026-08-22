import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/cubit/read_admin_range_finance_report_cubit.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/desktop/admin_range_finance_report_desktop.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/mobile/admin_range_finance_report_mobile.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/tablet/admin_range_finance_report_tablet.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';

class AdminRangeFinanceReportScreen extends StatelessWidget {
  const AdminRangeFinanceReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRepository = context.read<ReportsRepository>();
    return BlocProvider(
      create: (context) => ReadAdminRangeFinanceReportCubit(
        reportsRepository: reportsRepository,
      )..loadReport(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte Financiero por Rango"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop()) {
      return const AdminRangeFinanceReportDesktop();
    }

    if (context.isTablet()) {
      return const AdminRangeFinanceReportTablet();
    }

    return const AdminRangeFinanceReportMobile();
  }
}
