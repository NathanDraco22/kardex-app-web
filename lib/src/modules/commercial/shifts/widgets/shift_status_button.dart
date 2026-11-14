import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_state.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/open_shift_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/shift_management_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/gates/shifts_gate.dart';

class ShiftStatusButton extends StatelessWidget {
  final bool compact;

  const ShiftStatusButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ShiftsGate(
      child: BlocBuilder<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        builder: (context, _) {
          return BlocBuilder<ShiftCubit, ShiftState>(
            bloc: getIt<ShiftCubit>(),
            builder: (context, state) {
              if (state is ShiftFeatureDisabled || state is ShiftInitial) {
                return const SizedBox.shrink();
              }

              if (state is ShiftLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final shiftCubit = getIt<ShiftCubit>();

              if (shiftCubit.isBlockedByOtherBranch) {
                final active = shiftCubit.currentShift!;
                return _PillButton(
                  color: AppThemeTokens.danger,
                  icon: Icons.warning_amber_rounded,
                  label: compact
                      ? 'Otra sucursal'
                      : 'Turno en ${active.branchName}',
                  tooltip:
                      'Turno #${active.docNumber} abierto en ${active.branchName}. Toca para cambiar de sucursal.',
                  onTap: () => getIt<AuthCubit>().changeBranch(active.branchId),
                );
              }

              if (shiftCubit.isOpenInCurrentBranch) {
                final active = shiftCubit.currentShift!;
                return _PillButton(
                  color: AppThemeTokens.success,
                  icon: Icons.point_of_sale_rounded,
                  label: compact
                      ? '#${active.docNumber}'
                      : 'Turno #${active.docNumber} Activo',
                  tooltip: 'Gestionar caja del Turno #${active.docNumber}',
                  onTap: () => ShiftManagementDialog.show(context, shift: active),
                );
              }

              return _PillButton(
                color: AppThemeTokens.warning,
                icon: Icons.lock_open_rounded,
                label: compact ? 'Abrir Turno' : 'Abrir Turno',
                tooltip: 'Abrir un nuevo turno de caja',
                onTap: () => OpenShiftDialog.show(context),
              );
            },
          );
        },
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  const _PillButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
