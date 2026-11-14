import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_state.dart';
import 'package:kardex_app_front/widgets/gates/shifts_gate.dart';

/// Botón de acción compacto para abrir directamente los movimientos de efectivo
/// del turno activo en la sucursal actual. Se oculta si los turnos están
/// deshabilitados o si no hay turno abierto en la sucursal actual.
class ShiftCashMovementsIconButton extends StatelessWidget {
  const ShiftCashMovementsIconButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ShiftsGate(
      child: BlocBuilder<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        builder: (context, _) {
          return BlocBuilder<ShiftCubit, ShiftState>(
            bloc: getIt<ShiftCubit>(),
            builder: (context, state) {
              final shiftCubit = getIt<ShiftCubit>();
              if (!shiftCubit.isOpenInCurrentBranch) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.swap_vert_rounded),
                tooltip: "Movimientos del turno",
                onPressed: onPressed,
              );
            },
          );
        },
      ),
    );
  }
}
