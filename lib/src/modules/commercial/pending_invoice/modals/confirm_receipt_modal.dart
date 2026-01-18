import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

Future<bool?> showConfirmReceiptModal(
  BuildContext context,
  ClientInDb client,
  List<InvoiceInDb> invoices,
  String totalFormatted,
) async {
  bool? result;
  result = await showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.5,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(12),
      ),
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
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    client.location ?? "--",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "Facturas a Cancelar: ${invoices.length}",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "Total a Liquidar: $totalFormatted",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade900,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.amber.shade900,
                            ),
                          ),
                          child: Text(
                            "Se liquidarán el monto y las facturas seleccionadas en el estado de cuenta de cliente, esta accion no se puede revertir",
                            style: TextStyle(
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomSlider(
                    hintText: "Desliza para Liquidar",
                    hintIcon: Icons.save_alt,
                    sliderColor: Colors.teal.shade300,
                    sliderText: "Liquidar",
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

Future<bool?> showConfirmPartialPayReceipt(
  BuildContext context,
  ClientInDb client,
  int invoicesCount,
  String totalFormatted,
) async {
  bool? result;
  result = await showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.5,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(12),
      ),
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
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    client.location ?? "--",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "Facturas a Abonar: $invoicesCount",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "Total a Abonar: $totalFormatted",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade900,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.amber.shade900,
                            ),
                          ),
                          child: Text(
                            "Se abonará el monto a las facturas seleccionadas en el estado de cuenta de cliente, esta accion no se puede revertir",
                            style: TextStyle(
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomSlider(
                    hintText: "Desliza para Abonar",
                    hintIcon: Icons.save_alt,
                    sliderColor: Colors.teal.shade300,
                    sliderText: "Abonar",
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
