import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/admin_panel/admin_modules/admin_reports/range_executive_report/cubit/read_admin_range_finance_report_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';

class RangeFinanceFilterBar extends StatefulWidget {
  const RangeFinanceFilterBar({
    super.key,
    this.isCompact = false,
  });

  final bool isCompact;

  @override
  State<RangeFinanceFilterBar> createState() => _RangeFinanceFilterBarState();
}

class _RangeFinanceFilterBarState extends State<RangeFinanceFilterBar> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadAdminRangeFinanceReportCubit>();

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
                  FilledButton.icon(
                    onPressed: () {
                      readCubit.loadReport();
                    },
                    label: const Text("Filtrar"),
                    icon: const Icon(Icons.filter_alt_rounded),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      readCubit.clearFilters();
                      setState(() {});
                    },
                    child: const Icon(Icons.clear),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Wide / Toolbar mode for Tablet and Desktop
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
            FilledButton.icon(
              onPressed: () {
                readCubit.loadReport();
              },
              label: const Text("Filtrar"),
              icon: const Icon(Icons.filter_alt_rounded, size: 18),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: "Limpiar Filtros",
              onPressed: () {
                readCubit.clearFilters();
                setState(() {});
              },
              icon: const Icon(Icons.clear, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
