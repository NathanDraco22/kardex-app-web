import 'package:flutter/material.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/daily_summary/widgets/widgets.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';

class DailySummaryDetailScreen extends StatelessWidget {
  const DailySummaryDetailScreen({super.key, required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Resumen Diario: ${DateTimeTool.formatddMM(
            DateTime.fromMillisecondsSinceEpoch(summary.startDate),
          )}",
        ),
      ),
      body: _Body(summary: summary),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop()) {
      return _DailySummaryDesktop(summary: summary);
    }

    if (context.isTablet()) {
      return _DailySummaryTablet(summary: summary);
    }

    return _DailySummaryMobile(summary: summary);
  }
}

class _DailySummaryMobile extends StatelessWidget {
  const _DailySummaryMobile({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final hasBranches = summary.branches.isNotEmpty;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        children: [
          DailySalesSummaryCard(summary: summary),
          if (hasBranches) ...[
            const SizedBox(height: 8),
            DailySalesPieChartCard(summary: summary),
          ],
          const SizedBox(height: 16),
          DailyCashFlowSummaryCard(summary: summary),
          const SizedBox(height: 16),
          DailyOtherStatsCard(summary: summary),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _DailySummaryTablet extends StatelessWidget {
  const _DailySummaryTablet({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final hasBranches = summary.branches.isNotEmpty;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Fila 1: Ventas y Gráfico de Pastel
          if (hasBranches)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: DailySalesSummaryCard(summary: summary)),
                const SizedBox(width: 12),
                Expanded(child: DailySalesPieChartCard(summary: summary)),
              ],
            )
          else
            DailySalesSummaryCard(summary: summary),
          const SizedBox(height: 16),

          // Fila 2: Flujo de Caja y Otros Datos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DailyCashFlowSummaryCard(summary: summary)),
              const SizedBox(width: 12),
              Expanded(child: DailyOtherStatsCard(summary: summary)),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _DailySummaryDesktop extends StatelessWidget {
  const _DailySummaryDesktop({required this.summary});

  final DailySummaryInDb summary;

  @override
  Widget build(BuildContext context) {
    final hasBranches = summary.branches.isNotEmpty;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Sección 1: Ventas y Distribución por Sucursal
              if (hasBranches)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: DailySalesSummaryCard(summary: summary)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: DailySalesPieChartCard(summary: summary)),
                  ],
                )
              else
                DailySalesSummaryCard(summary: summary),
              const SizedBox(height: 20),

              // Sección 2: Flujo de Caja y Métricas Globales
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: DailyCashFlowSummaryCard(summary: summary)),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: DailyOtherStatsCard(summary: summary)),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
