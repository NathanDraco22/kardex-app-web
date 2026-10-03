import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class BranchRangeFilterBar extends StatefulWidget {
  const BranchRangeFilterBar({
    super.key,
    this.isCompact = false,
  });

  final bool isCompact;

  @override
  State<BranchRangeFilterBar> createState() => _BranchRangeFilterBarState();
}

class _BranchRangeFilterBarState extends State<BranchRangeFilterBar> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadReportsCubit>();

    if (widget.isCompact) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey(readCubit.startDate),
                      defaultDate: readCubit.startDate,
                      title: "Fecha Inicio",
                      onSelected: (value) {
                        readCubit.startDate = value;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                    child: VerticalDivider(),
                  ),
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey(readCubit.endDate),
                      defaultDate: readCubit.endDate,
                      title: "Fecha Fin",
                      onSelected: (value) {
                        readCubit.endDate = value;
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrimaryMenuButton(
                    onPressed: () {
                      readCubit.loadReports(getIt<AuthCubit>().currentBranchId);
                    },
                    label: const Text("Filtrar"),
                    icon: const Icon(Icons.filter_alt_rounded),
                  ),
                  const SizedBox(width: 8),
                  SecondaryMenuButton(
                    onPressed: () {
                      final now = DateTime.now();
                      readCubit.startDate = DateTime(now.year, now.month, 1);
                      readCubit.endDate = DateTimeTool.getTodayMidnight();
                      setState(() {});
                      readCubit.loadReports(getIt<AuthCubit>().currentBranchId);
                    },
                    label: const Text("Limpiar"),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Toolbar horizontal para Tablet y Desktop
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.teal),
            const SizedBox(width: 12),
            const Text(
              "Rango:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: DatePickerListTile(
                key: ValueKey(readCubit.startDate),
                defaultDate: readCubit.startDate,
                title: "Fecha Inicio",
                onSelected: (value) {
                  readCubit.startDate = value;
                },
              ),
            ),
            const SizedBox(
              height: 36,
              child: VerticalDivider(width: 24),
            ),
            Expanded(
              flex: 3,
              child: DatePickerListTile(
                key: ValueKey(readCubit.endDate),
                defaultDate: readCubit.endDate,
                title: "Fecha Fin",
                onSelected: (value) {
                  readCubit.endDate = value;
                },
              ),
            ),
            const SizedBox(width: 24),
            PrimaryMenuButton(
              onPressed: () {
                readCubit.loadReports(getIt<AuthCubit>().currentBranchId);
              },
              label: const Text("Filtrar"),
              icon: const Icon(Icons.filter_alt_rounded, size: 18),
            ),
            const SizedBox(width: 8),
            SecondaryMenuButton(
              tooltip: "Limpiar Filtros",
              onPressed: () {
                final now = DateTime.now();
                readCubit.startDate = DateTime(now.year, now.month, 1);
                readCubit.endDate = DateTimeTool.getTodayMidnight();
                setState(() {});
                readCubit.loadReports(getIt<AuthCubit>().currentBranchId);
              },
              label: const Text("Limpiar"),
              icon: const Icon(Icons.clear, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
