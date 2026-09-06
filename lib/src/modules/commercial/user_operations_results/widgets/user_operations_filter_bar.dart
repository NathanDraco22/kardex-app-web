import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/user_reports/read_user_reports_cubit.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/user_selection_dialog.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';

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

  Future<void> _pickUser(BuildContext context, ReadUserReportsCubit cubit) async {
    final (isSeller, _) = RoleTools.isSeller();
    if (isSeller) return;

    final selected = await showActiveUserSelectionDialog(context);
    if (selected != null) {
      cubit.setUser(selected, getIt<AuthCubit>().currentBranchId);
    }
  }

  Widget _buildUserSelector(BuildContext context, ReadUserReportsCubit cubit, {bool isExpanded = false}) {
    final (isSeller, _) = RoleTools.isSeller();
    final user = cubit.selectedUser;
    final userName = user != null ? user.username : "Todos los Usuarios";

    final btn = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(
        user != null ? Icons.person : Icons.group_outlined,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      label: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              userName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (user != null && !isSeller)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                cubit.setUser(null, getIt<AuthCubit>().currentBranchId);
              },
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            )
          else if (!isSeller)
            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
        ],
      ),
      onPressed: isSeller ? null : () => _pickUser(context, cubit),
    );

    return btn;
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
