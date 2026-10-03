import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/user_reports/read_user_reports_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/user_dropdown_selector.dart';

enum UserOperationsFilterBarMode {
  mobile,
  tablet,
  desktop,
}

class UserOperationsFilterBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final UserOperationsFilterBarMode mode;

  const UserOperationsFilterBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.mode = UserOperationsFilterBarMode.desktop,
  });

  Widget _buildUserSelector(BuildContext context, ReadUserReportsCubit cubit, {bool isExpanded = false}) {
    return UserDropdownSelector(
      selectedUser: cubit.selectedUser,
      isExpanded: isExpanded,
      allOptionText: "Todos los Usuarios",
      onChanged: (selected) {
        cubit.setUser(selected, getIt<AuthCubit>().currentBranchId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadUserReportsCubit>();

    if (mode == UserOperationsFilterBarMode.mobile) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserSelector(context, cubit, isExpanded: true),
              const SizedBox(height: 8),
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

    if (mode == UserOperationsFilterBarMode.tablet) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildUserSelector(context, cubit, isExpanded: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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
                ],
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: _buildUserSelector(context, cubit),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 240,
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
