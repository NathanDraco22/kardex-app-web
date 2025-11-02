import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

Future<bool?> showCancelDevolutionModal(
  BuildContext context,
  DevolutionInDb devolution,
) async {
  bool? result;
  result = await showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.4,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
    builder: (context) {
      final totalFormatted = NumberFormatter.convertToMoneyLike(devolution.total);
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  devolution.clientInfo.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Total a Cancelar: $totalFormatted",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all(color: Colors.amber.shade900)),
                        child: Text(
                          "Se va a CANCELAR la devolución, esta acción no se puede deshacer.",
                          style: TextStyle(color: Colors.amber.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CustomSlider(
                  hintText: "Desliza para Cancelar",
                  hintIcon: Icons.cancel,
                  sliderColor: Colors.red.shade300,
                  sliderText: "Cancelar",
                  onSubmit: () {
                    context.pop(true);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result;
}
