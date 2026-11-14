import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/open_shift_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';

class ShiftGuard {
  ShiftGuard._();

  static Future<bool> ensureShiftReady(BuildContext context) async {
    if (!getIt.isRegistered<AppSettingsCubit>() ||
        !getIt<AppSettingsCubit>().useShifts) {
      return true;
    }

    if (!getIt.isRegistered<ShiftCubit>()) {
      return true;
    }

    final shiftCubit = getIt<ShiftCubit>();

    if (shiftCubit.isBlockedByOtherBranch) {
      final activeShift = shiftCubit.currentShift!;
      final switchBranch = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppThemeTokens.danger),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Turno Abierto en Otra Sucursal',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Tienes el Turno #${activeShift.docNumber} abierto en la sucursal '
            '"${activeShift.branchName}". No puedes vender ni operar en otra sucursal '
            'mientras ese turno siga abierto.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Entendido'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: Text('Cambiar a ${activeShift.branchName}'),
            ),
          ],
        ),
      );

      if (switchBranch == true && getIt.isRegistered<AuthCubit>()) {
        await getIt<AuthCubit>().changeBranch(activeShift.branchId);
      }
      return false;
    }

    if (!shiftCubit.hasOpenShift) {
      final opened = await OpenShiftDialog.show(context);
      return opened != null;
    }

    return shiftCubit.isOpenInCurrentBranch;
  }
}
