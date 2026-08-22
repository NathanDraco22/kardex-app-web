import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/reports/read_reports_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';

enum DailyOperationsFilterBarMode {
  mobile,
  tablet,
  desktop,
}

class DailyOperationsFilterBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final DailyOperationsFilterBarMode mode;

  const DailyOperationsFilterBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.mode = DailyOperationsFilterBarMode.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadReportsCubit>();

    // 1. Modo Móvil (< 600 dp)
    if (mode == DailyOperationsFilterBarMode.mobile) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DatePickerButton(
                title: "Fecha de Operaciones",
                defaultDate: cubit.startDate,
                onSelected: (date) {
                  cubit.startDate = date;
                  cubit.endDate = date;
                  cubit.loadReports(getIt<AuthCubit>().currentBranchId);
                },
              ),
              const SizedBox(height: 10),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text("Resumen"),
                    icon: Icon(Icons.dashboard_rounded, size: 18),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text("Arqueo"),
                    icon: Icon(Icons.payments_rounded, size: 18),
                  ),
                ],
                selected: {currentIndex},
                onSelectionChanged: (Set<int> newSelection) {
                  onIndexChanged(newSelection.first);
                },
              ),
            ],
          ),
        ),
      );
    }

    // 2. Modo Tablet (600 a 839 dp) - Fecha centrada arriba y Segmented centrado una fila abajo
    if (mode == DailyOperationsFilterBarMode.tablet) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 280,
                child: DatePickerButton(
                  title: "Fecha de Operaciones",
                  defaultDate: cubit.startDate,
                  onSelected: (date) {
                    cubit.startDate = date;
                    cubit.endDate = date;
                    cubit.loadReports(getIt<AuthCubit>().currentBranchId);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      label: Text("Resumen General"),
                      icon: Icon(Icons.dashboard_rounded, size: 18),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text("Arqueo de Efectivo"),
                      icon: Icon(Icons.attach_money_rounded, size: 18),
                    ),
                  ],
                  selected: {currentIndex},
                  onSelectionChanged: (Set<int> newSelection) {
                    onIndexChanged(newSelection.first);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Modo Desktop (>= 840 dp) - Toolbar horizontal en una sola fila
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: DatePickerButton(
                title: "Fecha de Operaciones",
                defaultDate: cubit.startDate,
                onSelected: (date) {
                  cubit.startDate = date;
                  cubit.endDate = date;
                  cubit.loadReports(getIt<AuthCubit>().currentBranchId);
                },
              ),
            ),
            const Spacer(),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text("Resumen General"),
                  icon: Icon(Icons.dashboard_rounded, size: 18),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text("Arqueo de Efectivo"),
                  icon: Icon(Icons.attach_money_rounded, size: 18),
                ),
              ],
              selected: {currentIndex},
              onSelectionChanged: (Set<int> newSelection) {
                onIndexChanged(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
