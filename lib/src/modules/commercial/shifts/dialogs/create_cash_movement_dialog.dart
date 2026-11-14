import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/write_shift_cash_movements_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/shift_cash_movement_cubit/write_shift_cash_movements_state.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/dropdown/expense_category_dropdown.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:toastification/toastification.dart';

/// Muestra el diálogo para registrar una entrada o salida libre de efectivo en [shift].
Future<ShiftCashMovementInDb?> showCreateCashMovementDialog(
  BuildContext context, {
  required ShiftInDb shift,
  CashMovementType? initialType,
}) {
  return showDialog<ShiftCashMovementInDb?>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => BlocProvider(
      create: (_) => WriteShiftCashMovementsCubit(
        repository: ctx.read<ShiftCashMovementsRepository>(),
      ),
      child: CreateCashMovementDialog(
        shift: shift,
        initialType: initialType,
      ),
    ),
  );
}

class CreateCashMovementDialog extends StatefulWidget {
  final ShiftInDb shift;
  final CashMovementType? initialType;

  const CreateCashMovementDialog({
    super.key,
    required this.shift,
    this.initialType,
  });

  static Future<ShiftCashMovementInDb?> show(
    BuildContext context, {
    required ShiftInDb shift,
    CashMovementType? initialType,
  }) =>
      showCreateCashMovementDialog(
        context,
        shift: shift,
        initialType: initialType,
      );

  @override
  State<CreateCashMovementDialog> createState() => _CreateCashMovementDialogState();
}

class _CreateCashMovementDialogState extends State<CreateCashMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();

  late CashMovementType _type;
  bool _registerAsExpense = false;
  String? _expenseCategory;
  bool _loadingCategories = false;

  static const List<String> _inSuggestions = [
    'Fondo adicional',
    'Cambio inicial extra',
    'Aportación a caja',
    'Ajuste positivo',
  ];

  static const List<String> _outSuggestions = [
    'Garrafón de agua',
    'Insumos de limpieza',
    'Artículos de papelería',
    'Pago de mensajería',
    'Café y despensa',
    'Gasto operativo menor',
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? CashMovementType.inMovement;
    _ensureCategoriesLoaded();
  }

  Future<void> _ensureCategoriesLoaded() async {
    final repo = context.read<ExpenseCategoriesRepository>();
    if (repo.expenseCategories.isEmpty) {
      setState(() => _loadingCategories = true);
      try {
        await repo.getAllExpenseCategories();
      } catch (_) {}
      if (mounted) {
        setState(() => _loadingCategories = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = getIt<AuthCubit>().user;
    if (user == null) return;

    final amount = NumberFormatter.parseMoneyToCents(_amountController.text);
    final isOut = _type == CashMovementType.outMovement;

    final request = CreateShiftCashMovement(
      branchId: widget.shift.branchId,
      shiftId: widget.shift.id,
      type: _type,
      amount: amount,
      reason: _reasonController.text.trim(),
      registerAsExpense: isOut && _registerAsExpense,
      expenseCategory: (isOut && _registerAsExpense) ? _expenseCategory : null,
      createdBy: UserInfo(
        id: user.id,
        name: user.username,
      ),
    );

    final created =
        await context.read<WriteShiftCashMovementsCubit>().createMovement(request);
    if (!mounted) return;
    if (created != null) {
      if (getIt.isRegistered<ShiftCubit>() &&
          getIt<ShiftCubit>().currentShift?.id == widget.shift.id) {
        await getIt<ShiftCubit>().loadActiveShift();
      }
      if (!mounted) return;
      toastification.show(
        context: context,
        title: Text(
          _type == CashMovementType.inMovement
              ? 'Entrada de caja registrada'
              : 'Salida de caja registrada',
        ),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOut = _type == CashMovementType.outMovement;

    return BlocConsumer<WriteShiftCashMovementsCubit, WriteShiftCashMovementsState>(
      listener: (context, state) {
        if (state is WriteShiftCashMovementsError) {
          toastification.show(
            context: context,
            title: const Text('Error al registrar movimiento'),
            description: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WriteShiftCashMovementsLoading;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isOut ? AppThemeTokens.danger : AppThemeTokens.success)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isOut ? Icons.outbox_rounded : Icons.move_to_inbox_rounded,
                  color: isOut ? AppThemeTokens.danger : AppThemeTokens.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Movimiento de Efectivo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Turno #${widget.shift.docNumber}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<CashMovementType>(
                      segments: const [
                        ButtonSegment(
                          value: CashMovementType.inMovement,
                          icon: Icon(Icons.add_circle_outline_rounded),
                          label: Text('Entrada (+)'),
                        ),
                        ButtonSegment(
                          value: CashMovementType.outMovement,
                          icon: Icon(Icons.remove_circle_outline_rounded),
                          label: Text('Salida (-)'),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: isLoading
                          ? null
                          : (selection) {
                              setState(() {
                                _type = selection.first;
                                if (_type == CashMovementType.inMovement) {
                                  _registerAsExpense = false;
                                }
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppThemeTokens.surfaceLight,
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        border: Border.all(color: AppThemeTokens.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            size: 20,
                            color: AppThemeTokens.indigo,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Efectivo esperado en caja del turno:',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppThemeTokens.neutral,
                                  ),
                                ),
                                Text(
                                  NumberFormatter.convertToMoneyLike(
                                    widget.shift.expectedCash,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      enabled: !isLoading,
                      autofocus: true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: const [DecimalTextInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        prefixText: '${NumberFormatter.currencySymbol} ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        final cents = NumberFormatter.parseMoneyToCents(
                          value ?? '',
                        );
                        if (cents <= 0) {
                          return 'El monto debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _reasonController,
                      enabled: !isLoading,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Motivo / Descripción',
                        prefixIcon: const Icon(Icons.description_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa el motivo del movimiento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (isOut ? _outSuggestions : _inSuggestions)
                          .map(
                            (suggestion) => ActionChip(
                              label: Text(
                                suggestion,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      _reasonController.text = suggestion;
                                    },
                            ),
                          )
                          .toList(),
                    ),
                    if (isOut) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: _registerAsExpense,
                              onChanged: isLoading
                                  ? null
                                  : (val) => setState(() => _registerAsExpense = val ?? false),
                              title: const Text(
                                'Registrar como gasto operativo',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text(
                                'Crea automáticamente un gasto pagado vinculado a este turno',
                                style: TextStyle(fontSize: 12),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            if (_registerAsExpense)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                child: _loadingCategories
                                    ? const LinearProgressIndicator()
                                    : ExpenseCategoryDropdown(
                                        value: _expenseCategory,
                                        isRequired: true,
                                        onChanged: (val) => setState(() => _expenseCategory = val),
                                        validator: (val) {
                                          if (_registerAsExpense &&
                                              (val == null || val.trim().isEmpty)) {
                                            return 'Selecciona una categoría de gasto';
                                          }
                                          return null;
                                        },
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor:
                    isOut ? AppThemeTokens.danger : AppThemeTokens.success,
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(isLoading ? 'Guardando...' : 'Registrar'),
            ),
          ],
        );
      },
    );
  }
}
