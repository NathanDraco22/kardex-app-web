import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<CommercialProductResult?> showCommercialProductModal(
  BuildContext context, {
  required ProductInDbInBranch product,
}) async {
  return await Navigator.push<CommercialProductResult?>(
    context,
    MaterialPageRoute(
      builder: (context) => CommercialProductModal(
        product: product,
      ),
    ),
  );
}

class CommercialProductModal extends StatefulWidget {
  const CommercialProductModal({super.key, required this.product});

  final ProductInDbInBranch product;

  @override
  State<CommercialProductModal> createState() => _CommercialProductModalState();
}

class _CommercialProductModalState extends State<CommercialProductModal> {
  late CommercialProductResult commercialProductResult;
  late Iterable<DropdownMenuItem<Discount>> discountsAvailable;
  FocusNode focusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    commercialProductResult = CommercialProductResult(product: widget.product);
    discountsAvailable = widget.product.saleProfile.discounts.map(
      (e) {
        return DropdownMenuItem(
          value: e,
          child: Text(
            "${e.name} (${e.percentValue}%)",
          ),
        );
      },
    );
    Future(
      () {
        focusNode.requestFocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = commercialProductResult.product;
    final price = NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice);
    final subtotal = NumberFormatter.convertToMoneyLike(commercialProductResult.subTotal);
    final totalDiscount = NumberFormatter.convertToMoneyLike(commercialProductResult.totalDiscount);
    final total = NumberFormatter.convertToMoneyLike(commercialProductResult.total);
    return Form(
      key: formKey,
      child: Scaffold(
        appBar: AppBar(title: const Text("Busqueda de Producto Comercial")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  TitleLabel(
                    title: "Marca",
                    bigTitle: widget.product.brandName,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  TitleLabel(
                    title: "Unidad",
                    bigTitle: widget.product.unitName,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 12),

                    SizedBox(
                      width: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                child: TitleLabel(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12,
                                  title: "Existencia",
                                  bigTitle: widget.product.account.availableStock.toString(),
                                ),
                              ),

                              Flexible(
                                fit: FlexFit.tight,

                                child: SizedBox(
                                  height: 90,
                                  child: TitleTextField(
                                    focusNode: focusNode,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "";
                                      }

                                      final numberValue = int.tryParse(value) ?? 0;

                                      if (numberValue == 0) {
                                        return "Cantidad invalida";
                                      }

                                      if (numberValue > widget.product.account.availableStock) {
                                        return "Cantidad invalida";
                                      }

                                      return null;
                                    },
                                    titleTextAlign: TextAlign.center,
                                    initialValue: commercialProductResult.quantity.toString(),
                                    inputFormatters: [IntegerTextInputFormatter()],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      commercialProductResult.quantity = int.tryParse(value) ?? 0;
                                      setState(() {});
                                    },
                                    title: "Cantidad",
                                  ),
                                ),
                              ),

                              Flexible(
                                fit: FlexFit.tight,

                                child: TitleLabel(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12,
                                  title: "Precio",
                                  bigTitle: price,
                                ),
                              ),
                              Flexible(
                                fit: FlexFit.tight,
                                child: TitleLabel(
                                  spacing: 12,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  title: "SubTotal",
                                  bigTitle: subtotal,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Descuentos Disponibles",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField(
                            initialValue: commercialProductResult.selectedDisocunt,
                            items: discountsAvailable.toList(),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  commercialProductResult.selectedDisocunt = null;
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            onChanged: (value) {
                              commercialProductResult.selectedDisocunt = value;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 140,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 120,
                            child: Text(
                              "Total Descuento: ",
                              textAlign: TextAlign.end,
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: Text(
                              totalDiscount,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 120,
                            child: Text(
                              "Total: ",
                              textAlign: TextAlign.end,
                            ),
                          ),
                          const Divider(),
                          SizedBox(
                            width: 140,
                            child: Text(
                              total,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 36,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancelar",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final isValid = formKey.currentState!.validate();

                        if (!isValid) {
                          return;
                        }

                        if (commercialProductResult.quantity == 0) {
                          Navigator.pop(context);
                        }
                        Navigator.pop(context, commercialProductResult);
                      },
                      child: const Text(
                        "Aceptar",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
