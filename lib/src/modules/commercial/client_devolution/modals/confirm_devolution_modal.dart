import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';

import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

Future<bool?> showConfirmationDevolutionModal(
  BuildContext context,
  CreateDevolution createDevolution,
) async {
  bool? result;

  // Formatea el total para mostrarlo
  final totalFormatted = NumberFormatter.convertToMoneyLike(createDevolution.total);

  result = await showModalBottomSheet<bool>(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.6, // Ajusta la altura si es necesario
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Resumen de la Devolución ---
                  Text(
                    createDevolution.clientInfo.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Items a devolver: ${createDevolution.returnedItems.length}",
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Total de la Devolución: $totalFormatted",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // --- Mensaje de Advertencia ---
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.amber.shade900),
                          ),
                          child: Text(
                            "Se creará una devolución. Esta acción afectará el inventario y el estado de cuenta del cliente, y no se puede revertir.",
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // --- Acción de Confirmación ---
                  CustomSlider(
                    hintText: "Desliza para Confirmar Devolución",
                    hintIcon: Icons.undo,
                    sliderColor: Colors.orange.shade300,
                    sliderText: "Devolver",
                    onSubmit: () {
                      context.pop(true);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return result;
}
