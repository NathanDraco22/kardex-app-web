import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/reset_inventory/reset_inventory_cubit.dart';
import 'package:kardex_app_front/src/cubits/reset_inventory/reset_inventory_state.dart';
import 'package:kardex_business/kardex_business.dart';

Future<ResetInventoryResult?> showResetInventoryDangerDialog(
  BuildContext context, {
  required BranchInDb branch,
}) async {
  return showDialog<ResetInventoryResult>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BlocProvider(
        create: (context) => ResetInventoryCubit(
          repository: context.read<InventoriesRepository>(),
        ),
        child: _ResetInventoryDangerDialog(branch: branch),
      );
    },
  );
}

class _ResetInventoryDangerDialog extends StatefulWidget {
  final BranchInDb branch;

  const _ResetInventoryDangerDialog({required this.branch});

  @override
  State<_ResetInventoryDangerDialog> createState() =>
      _ResetInventoryDangerDialogState();
}

class _ResetInventoryDangerDialogState
    extends State<_ResetInventoryDangerDialog> {
  static const int _initialCountdown = 10;
  int _secondsRemaining = _initialCountdown;
  Timer? _timer;

  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _startCountdown();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _secondsRemaining = 0;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCountdownDone = _secondsRemaining == 0;
    final bool isNameMatch =
        _textController.text.trim() == widget.branch.name.trim();

    return BlocConsumer<ResetInventoryCubit, ResetInventoryState>(
      listener: (context, state) {
        if (state is ResetInventorySuccess) {
          Navigator.of(context).pop(state.result);
        } else if (state is ResetInventoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is ResetInventoryLoading;
        final bool canSubmit = isCountdownDone && isNameMatch && !isLoading;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.red.shade300, width: 1.5),
          ),
          backgroundColor: Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado de Peligro
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Zona de Peligro",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              "Reiniciar Inventario a Cero",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLoading)
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(null),
                          tooltip: "Cerrar",
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Caja de advertencia Bento
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.storefront_rounded,
                                size: 18, color: Colors.red.shade900),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Sucursal a afectar: ${widget.branch.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "• Esta acción generará un ajuste de salida automático que dejará en 0 existencias todos los productos con stock en esta sede.\n"
                          "• Esta operación es IRREVERSIBLE y quedará asentada formalmente en el Kardex y movimientos contables.\n"
                          "• Se reiniciará también cualquier apartado de órdenes pendientes en esta sucursal.",
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Contador regresivo visual
                  if (!isCountdownDone) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              value:
                                  (_initialCountdown - _secondsRemaining) /
                                      _initialCountdown,
                              strokeWidth: 2.5,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Por seguridad, espere $_secondsRemaining segundos para habilitar la confirmación...",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.green.shade300, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18, color: Colors.green.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Tiempo de espera cumplido. Escriba el nombre exacto para continuar.",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Campo de texto de confirmación
                  Text(
                    "Para confirmar, escribe exactamente \"${widget.branch.name}\":",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _textController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: widget.branch.name,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isNameMatch
                              ? Colors.green.shade600
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isNameMatch
                              ? Colors.green.shade600
                              : Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(null),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          disabledBackgroundColor: Colors.red.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: canSubmit
                            ? () {
                                final authCubit = getIt<AuthCubit>();
                                final user = authCubit.user;
                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Error: No se encontró sesión de usuario activa"),
                                    ),
                                  );
                                  return;
                                }

                                context
                                    .read<ResetInventoryCubit>()
                                    .resetBranchInventory(
                                      branchId: widget.branch.id,
                                      branchNameConfirm:
                                          _textController.text.trim(),
                                      description:
                                          "Reinicio de inventario a 0 (Zona de Peligro)",
                                      createdBy: UserInfo(
                                        id: user.id,
                                        name: user.username,
                                      ),
                                    );
                              }
                            : null,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.delete_forever_rounded,
                                size: 18),
                        label: Text(
                          isLoading
                              ? "Procesando ajuste..."
                              : !isCountdownDone
                                  ? "Espere ${_secondsRemaining}s..."
                                  : "Reiniciar Inventario a 0",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
