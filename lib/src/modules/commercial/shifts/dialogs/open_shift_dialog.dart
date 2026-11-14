import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/write_shifts_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/write_shifts_state.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:toastification/toastification.dart';

class OpenShiftDialog extends StatefulWidget {
  const OpenShiftDialog({super.key});

  static Future<ShiftInDb?> show(BuildContext context) {
    return showDialog<ShiftInDb?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider(
        create: (_) => WriteShiftsCubit(
          shiftsRepository: ctx.read<ShiftsRepository>(),
        ),
        child: const OpenShiftDialog(),
      ),
    );
  }

  @override
  State<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends State<OpenShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _initialCashController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _initialCashController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authCubit = getIt<AuthCubit>();
    final user = authCubit.user;
    if (user == null) return;

    final initialCash =
        NumberFormatter.parseMoneyToCents(_initialCashController.text);

    final request = CreateShift(
      branchId: authCubit.currentBranchId,
      branchName: authCubit.currentBranchName,
      initialCash: initialCash,
      openingNotes: _notesController.text.trim(),
      openedBy: UserInfo(
        id: user.id,
        name: user.username,
      ),
    );

    final created = await context.read<WriteShiftsCubit>().openShift(request);
    if (!mounted) return;
    if (created != null) {
      toastification.show(
        context: context,
        title: Text('Turno #${created.docNumber} abierto'),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return BlocConsumer<WriteShiftsCubit, WriteShiftsState>(
      listener: (context, state) {
        if (state is WriteShiftsError) {
          toastification.show(
            context: context,
            title: const Text('No se pudo abrir el turno'),
            description: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is WriteShiftsLoading;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemeTokens.warning.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.point_of_sale_rounded,
                  color: AppThemeTokens.warning,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abrir Turno de Caja',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Registra el fondo inicial para comenzar a operar',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_outlined, size: 18, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sucursal: ${authCubit.currentBranchName}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _initialCashController,
                    enabled: !isLoading,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: const [DecimalTextInputFormatter()],
                    decoration: InputDecoration(
                      labelText: 'Fondo inicial en caja',
                      prefixIcon: const Icon(Icons.payments_outlined),
                      prefixText: '${NumberFormatter.currencySymbol} ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return 'Ingresa un monto válido (0 o mayor)';
                      }
                      final cents = NumberFormatter.parseMoneyToCents(trimmed);
                      if (cents < 0) {
                        return 'Ingresa un monto válido (0 o mayor)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesController,
                    enabled: !isLoading,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Observaciones de apertura (opcional)',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
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
                backgroundColor: AppThemeTokens.success,
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
                  : const Icon(Icons.lock_open_rounded),
              label: Text(isLoading ? 'Abriendo...' : 'Abrir Turno'),
            ),
          ],
        );
      },
    );
  }
}
