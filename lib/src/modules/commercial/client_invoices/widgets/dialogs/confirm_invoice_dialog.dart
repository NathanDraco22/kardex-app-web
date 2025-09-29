import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

Future<bool> showConfirmationInvoiceDialog(
  BuildContext context,
  ClientInDb client,
  CreateInvoice createInvoice, {
  bool isOrder = false,
}) async {
  bool result = false;
  String title = "Facturar a Cliente";
  if (isOrder) title = "Orden de Compra";

  String slideWord = "Facturar";
  if (isOrder) slideWord = "Enviar";
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Column(
          children: [
            Text(title),
            Text(client.name),
          ],
        ),
        content: SizedBox(
          height: 600,
          width: 600,
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(height: 2.0),
                  itemCount: createInvoice.saleItems.length,
                  itemBuilder: (context, index) {
                    final item = createInvoice.saleItems[index];
                    return Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Text(item.product.name),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(item.quantity.toString()),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(item.price),
                          ),
                        ),

                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(item.totalDiscount),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(item.total),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    "Total: ${NumberFormatter.convertToMoneyLike(createInvoice.total)}",
                  ),
                ],
              ),

              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: CustomSlider(
                      hintText: "Desliza para $slideWord",
                      hintIcon: Icons.save,
                      sliderColor: Colors.green.shade300,
                      sliderText: slideWord,
                      onSubmit: () {
                        result = true;
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result;
}

Future<bool> showConfirmationAnonInvoiceDialog(
  BuildContext context,
  CreateInvoice createInvoice,
) async {
  bool result = false;
  String title = "Facturar Productos";

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Column(
          children: [
            Text(title),
          ],
        ),
        content: SizedBox(
          height: 600,
          width: 600,
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(height: 2.0),
                  itemCount: createInvoice.saleItems.length,
                  itemBuilder: (context, index) {
                    final item = createInvoice.saleItems[index];
                    return Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Text(item.product.name),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(item.quantity.toString()),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(item.price),
                          ),
                        ),

                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(item.totalDiscount),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(item.total),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    "Total: ${NumberFormatter.convertToMoneyLike(createInvoice.total)}",
                  ),
                ],
              ),

              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: CustomSlider(
                      hintText: "Desliza para Facturar",
                      hintIcon: Icons.save,
                      sliderColor: Colors.green.shade300,
                      sliderText: "Facturar",
                      onSubmit: () {
                        result = true;
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result;
}
