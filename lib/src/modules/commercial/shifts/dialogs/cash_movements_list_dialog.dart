import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/read_shift_cash_movements_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/read_shift_cash_movements_state.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/write_shift_cash_movements_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/write_shift_cash_movements_state.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/create_cash_movement_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:toastification/toastification.dart';

/// Muestra el visualizador y gestor de movimientos libres de efectivo de [shift].
Future<bool?> showCashMovementsListDialog(
  BuildContext context, {
  required ShiftInDb shift,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadShiftCashMovementsCubit(
            repository: ctx.read<ShiftCashMovementsRepository>(),
            shiftId: shift.id,
          )..loadMovements(),
        ),
        BlocProvider(
          create: (_) => WriteShiftCashMovementsCubit(
            repository: ctx.read<ShiftCashMovementsRepository>(),
          ),
        ),
      ],
      child: CashMovementsListDialog(shift: shift),
    ),
  );
}

class CashMovementsListDialog extends StatefulWidget {
  final ShiftInDb shift;

  const CashMovementsListDialog({
    super.key,
    required this.shift,
  });

  @override
  State<CashMovementsListDialog> createState() => _CashMovementsListDialogState();
}

class _CashMovementsListDialogState extends State<CashMovementsListDialog> {
  final _dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
  bool _hasModified = false;
  bool _isProcessing = false;

  void _loadMovements() {
    if (!mounted) return;
    context.read<ReadShiftCashMovementsCubit>().loadMovements();
  }

  Future<void> _syncActiveShiftIfNeeded() async {
    if (!getIt.isRegistered<ShiftCubit>()) return;
    final shiftCubit = getIt<ShiftCubit>();
    if (shiftCubit.currentShift?.id == widget.shift.id) {
      await shiftCubit.loadActiveShift();
    }
  }

  ShiftInDb get _currentShiftContext {
    if (getIt.isRegistered<ShiftCubit>()) {
      final active = getIt<ShiftCubit>().currentShift;
      if (active != null && active.id == widget.shift.id) {
        return active;
      }
    }
    return widget.shift;
  }

  Future<void> _confirmDeleteMovement(ShiftCashMovementInDb movement) async {
    final isIn = movement.type == CashMovementType.inMovement;
    final color = isIn ? AppThemeTokens.success : AppThemeTokens.danger;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusLg),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppThemeTokens.danger,
              size: 26,
            ),
            SizedBox(width: 10),
            Text('Confirmar Anulación'),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de anular esta ${isIn ? "entrada" : "salida"} de efectivo?',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemeTokens.surfaceLight,
                  borderRadius: AppThemeTokens.borderRadiusMd,
                  border: Border.all(color: AppThemeTokens.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${movement.docNumber} • ${movement.reason}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Monto: ${isIn ? "+" : "-"}${NumberFormatter.convertToMoneyLike(movement.amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppThemeTokens.danger.withValues(alpha: 0.08),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(
                    color: AppThemeTokens.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppThemeTokens.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        movement.expenseId != null
                            ? 'Esta acción revertirá el impacto en caja del turno y también eliminará el gasto operativo vinculado.'
                            : 'Esta acción revertirá automáticamente el impacto en el efectivo esperado del turno.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppThemeTokens.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppThemeTokens.danger,
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Sí, Anular Movimiento'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    final writeCubit = context.read<WriteShiftCashMovementsCubit>();
    final deleted = await writeCubit.deleteMovement(movement.id);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final writeState = writeCubit.state;
    if (deleted == null && writeState is WriteShiftCashMovementsError) {
      toastification.show(
        context: context,
        title: const Text('No fue posible anular'),
        description: Text(writeState.message),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 4),
      );
      return;
    }

    _hasModified = true;
    toastification.show(
      context: context,
      title: const Text('Movimiento anulado'),
      description: const Text('El saldo del turno fue actualizado.'),
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 3),
    );
    await _syncActiveShiftIfNeeded();
    _loadMovements();
  }

  Future<void> _openCreateDialog() async {
    final created = await showCreateCashMovementDialog(
      context,
      shift: _currentShiftContext,
    );
    if (created != null && mounted) {
      _hasModified = true;
      await _syncActiveShiftIfNeeded();
      _loadMovements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authCubit = getIt<AuthCubit>();
    final isOpen = widget.shift.status == ShiftStatus.open;

    return PopScope(
      canPop: !_isProcessing,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusLg),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
          child: BlocBuilder<AuthCubit, AuthState>(
            bloc: authCubit,
            builder: (context, _) {
              final isShiftInCurrentBranch =
                  widget.shift.branchId == authCubit.currentBranchId;
              final currentBranchName =
                  authCubit.currentBranch?.name ?? authCubit.currentBranchId;
              final shiftBranchName = widget.shift.branchName.isNotEmpty
                  ? widget.shift.branchName
                  : widget.shift.branchId;

              return Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: AppThemeTokens.cardBg,
                      border: Border(
                        bottom: BorderSide(color: AppThemeTokens.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppThemeTokens.indigo.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: AppThemeTokens.indigo,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Movimientos del Turno #${widget.shift.docNumber}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (isOpen
                                              ? AppThemeTokens.success
                                              : AppThemeTokens.neutral)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (isOpen
                                                ? AppThemeTokens.success
                                                : AppThemeTokens.neutral)
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Text(
                                      isOpen ? 'ABIERTO' : 'CERRADO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isOpen
                                            ? AppThemeTokens.success
                                            : AppThemeTokens.neutral,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Historial de entradas y salidas libres registradas bajo este turno',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppThemeTokens.neutral,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          tooltip: 'Refrescar movimientos',
                          onPressed: _isProcessing ? null : _loadMovements,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'Cerrar',
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.of(context).pop(_hasModified),
                        ),
                      ],
                    ),
                  ),

                  if (!isShiftInCurrentBranch)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      color: AppThemeTokens.warning.withValues(alpha: 0.15),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Colors.amber.shade900,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Este turno pertenece a "$shiftBranchName". Estás en "$currentBranchName". Cambia de sucursal para registrar o anular movimientos.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              authCubit.changeBranch(widget.shift.branchId);
                              Navigator.of(context).pop(_hasModified);
                            },
                            child: const Text('Cambiar'),
                          ),
                        ],
                      ),
                    ),

                  // Body Content
                  Expanded(
                    child: BlocBuilder<ReadShiftCashMovementsCubit,
                        ReadShiftCashMovementsState>(
                      builder: (context, state) {
                        var movements = <ShiftCashMovementInDb>[];
                        var isLoading = false;
                        String? errorMessage;

                        if (state is ReadShiftCashMovementsLoading ||
                            state is ReadShiftCashMovementsInitial) {
                          isLoading = true;
                        } else if (state is ReadShiftCashMovementsError) {
                          errorMessage = state.message;
                        } else if (state is ReadShiftCashMovementsLoaded) {
                          movements = state.movements
                              .where((m) => !m.isDeleted)
                              .toList();
                        }

                        final totalInCents = movements
                            .where((m) => m.type == CashMovementType.inMovement)
                            .fold<int>(0, (sum, m) => sum + m.amount);
                        final totalOutCents = movements
                            .where((m) => m.type == CashMovementType.outMovement)
                            .fold<int>(0, (sum, m) => sum + m.amount);
                        final netCents = totalInCents - totalOutCents;
                        final netPrefix =
                            netCents > 0 ? '+' : (netCents < 0 ? '-' : '');

                        return Column(
                          children: [
                            // Metric Bar
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _MetricCard(
                                      label: 'Total Entradas Libres',
                                      amount:
                                          '+${NumberFormatter.convertToMoneyLike(totalInCents)}',
                                      icon: Icons.arrow_downward_rounded,
                                      color: AppThemeTokens.success,
                                      bgColor: AppThemeTokens.success
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MetricCard(
                                      label: 'Total Salidas / Retiros',
                                      amount:
                                          '-${NumberFormatter.convertToMoneyLike(totalOutCents)}',
                                      icon: Icons.arrow_upward_rounded,
                                      color: AppThemeTokens.danger,
                                      bgColor: AppThemeTokens.danger
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _MetricCard(
                                      label: 'Impacto Neto en Caja',
                                      amount:
                                          '$netPrefix${NumberFormatter.convertToMoneyLike(netCents.abs())}',
                                      icon:
                                          Icons.account_balance_wallet_outlined,
                                      color: netCents >= 0
                                          ? AppThemeTokens.indigo
                                          : AppThemeTokens.danger,
                                      bgColor: AppThemeTokens.surfaceLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Movements List / States
                            Expanded(
                              child: isLoading && movements.isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : errorMessage != null
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.error_outline_rounded,
                                                  size: 40,
                                                  color: AppThemeTokens.danger,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Error al cargar movimientos: $errorMessage',
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 12),
                                                OutlinedButton.icon(
                                                  onPressed: _loadMovements,
                                                  icon: const Icon(
                                                    Icons.refresh_rounded,
                                                    size: 18,
                                                  ),
                                                  label: const Text('Reintentar'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : movements.isEmpty
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.inbox_outlined,
                                                    size: 48,
                                                    color: AppThemeTokens.neutral
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'No hay movimientos registrados',
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: AppThemeTokens
                                                          .neutral,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    isOpen
                                                        ? 'Registra una entrada o salida libre con el botón inferior.'
                                                        : 'Este turno no tuvo movimientos libres.',
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: AppThemeTokens
                                                          .neutral,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ListView.separated(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              itemCount: movements.length,
                                              separatorBuilder: (_, _) =>
                                                  const SizedBox(height: 8),
                                              itemBuilder: (context, index) {
                                                final movement = movements[index];
                                                return _MovementTile(
                                                  movement: movement,
                                                  canDelete: isOpen &&
                                                      isShiftInCurrentBranch &&
                                                      !_isProcessing,
                                                  formattedTime: _dateFormat
                                                      .format(movement.createdAt),
                                                  onDelete: () =>
                                                      _confirmDeleteMovement(
                                                    movement,
                                                  ),
                                                );
                                              },
                                            ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // Footer Actions
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    color: AppThemeTokens.cardBg,
                    child: Row(
                      children: [
                        if (!isOpen)
                          const Row(
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: AppThemeTokens.neutral,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Turno cerrado: movimientos de solo lectura.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppThemeTokens.neutral,
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.of(context).pop(_hasModified),
                          child: const Text('Cerrar'),
                        ),
                        if (isOpen) ...[
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: AppThemeTokens.borderRadiusSm,
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Nuevo Movimiento'),
                            onPressed: (_isProcessing || !isShiftInCurrentBranch)
                                ? null
                                : _openCreateDialog,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppThemeTokens.neutral,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final ShiftCashMovementInDb movement;
  final bool canDelete;
  final String formattedTime;
  final VoidCallback onDelete;

  const _MovementTile({
    required this.movement,
    required this.canDelete,
    required this.formattedTime,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIn = movement.type == CashMovementType.inMovement;
    final color = isIn ? AppThemeTokens.success : AppThemeTokens.danger;
    final bgColor = color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppThemeTokens.cardBg,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        movement.type.display.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (movement.docNumber.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeTokens.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppThemeTokens.borderLight),
                        ),
                        child: Text(
                          '#${movement.docNumber}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppThemeTokens.neutral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (movement.registerAsExpense)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeTokens.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Gasto • ${movement.expenseCategory ?? 'General'}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  movement.reason,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppThemeTokens.neutral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.neutral,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: AppThemeTokens.neutral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      movement.createdBy.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.neutral,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIn ? "+" : "-"}${NumberFormatter.convertToMoneyLike(movement.amount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (canDelete) ...[
                const SizedBox(height: 4),
                IconButton(
                  tooltip: 'Anular movimiento',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppThemeTokens.danger,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
