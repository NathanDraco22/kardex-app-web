import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/repositories/product_repository.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<CommercialProductResult?> showCommercialProductModalFromId(
  BuildContext context, {
  required String productId,
  SaleItem? previousSaleItem,
}) async {
  final authState = getIt<AuthCubit>().state;
  if (authState is! Authenticated) return null;
  final branchId = authState.branch.id;

  LoadingDialogManager.showLoadingDialog(context);
  try {
    final product = await context
        .read<ProductsRepository>()
        .getProductInBranchById(productId, branchId)
        .timeout(const Duration(seconds: 10));
    if (!context.mounted) return null;
    LoadingDialogManager.closeLoadingDialog(context);

    CommercialProductResult? initialResult;
    if (previousSaleItem != null) {
      Discount? appliedDiscount;
      if (previousSaleItem.discountPercentage > 0) {
        final match = product.saleProfile.discounts.where(
          (d) => d.percentValue == previousSaleItem.discountPercentage,
        );
        if (match.isNotEmpty) {
          appliedDiscount = match.first;
        } else {
          appliedDiscount = Discount(
            name: "Descuento",
            percentValue: previousSaleItem.discountPercentage,
            isActive: true,
          );
        }
      }

      initialResult = CommercialProductResult(product: product)
        ..quantity = previousSaleItem.quantity
        ..selectedPriceLevel = previousSaleItem.selectedPrice
        ..newPrice = previousSaleItem.price
        ..selectedDisocunt = appliedDiscount;
    }

    return await showCommercialProductModal(
      context,
      product: product,
      commercialProductResult: initialResult,
    );
  } catch (e) {
    if (context.mounted) {
      LoadingDialogManager.closeLoadingDialog(context);
      DialogManager.showErrorDialog(context, "Error al obtener el producto: $e");
    }
    return null;
  }
}

Future<CommercialProductResult?> showCommercialProductModal(
  BuildContext context, {
  required ProductInDbInBranch product,
  CommercialProductResult? commercialProductResult,
}) async {
  return await Navigator.push<CommercialProductResult?>(
    context,
    MaterialPageRoute(
      builder: (context) => CommercialProductModal(
        product: product,
        commercialProductResult: commercialProductResult,
      ),
    ),
  );
}

class CommercialProductModal extends StatefulWidget {
  const CommercialProductModal({super.key, required this.product, this.commercialProductResult});

  final ProductInDbInBranch product;
  final CommercialProductResult? commercialProductResult;

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

    if (widget.commercialProductResult != null) {
      commercialProductResult = widget.commercialProductResult!.copyWith();
    } else {
      commercialProductResult = CommercialProductResult(product: widget.product);
    }
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
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final isUserAdmin = authState.session.user.role == "Admin";
    final product = commercialProductResult.product;
    double price = NumberFormatter.convertFromCentsToDouble(commercialProductResult.newPrice);
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
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              Text(
                widget.product.displayCode,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              const SizedBox(height: 8),
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
                          const Text(
                            "Nivel de Precio",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<int>(
                            value: commercialProductResult.selectedPriceLevel,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(
                                value: 1,
                                child: Text(
                                  "Precio 1 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice)})",
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text(
                                  "Precio 2 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice2)})",
                                ),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text(
                                  "Precio 3 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice3)})",
                                ),
                              ),
                              if (isUserAdmin)
                                const DropdownMenuItem(
                                  value: 0,
                                  child: Text("Precio manual"),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              final priceMap = {
                                1: product.saleProfile.salePrice,
                                2: product.saleProfile.salePrice2,
                                3: product.saleProfile.salePrice3,
                              };

                              if (priceMap[value] == 0) {
                                return;
                              }

                              commercialProductResult.selectedPriceLevel = value;
                              if (value != 0) {
                                commercialProductResult.newPrice = priceMap[value]!;
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TitleLabel(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  title: "Existencia",
                                  bigTitle: widget.product.account.availableStock.toString(),
                                ),
                              ),
                              Expanded(
                                child: Visibility(
                                  visible: isUserAdmin,
                                  child: Row(
                                    mainAxisAlignment: .spaceEvenly,
                                    children: [
                                      TitleLabel(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        title: "Costo",
                                        bigTitle: NumberFormatter.convertFromCentsToUnitsCurrency(
                                          widget.product.account.averageCost,
                                        ),
                                      ),
                                      TitleLabel(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        title: "Ult. C",
                                        bigTitle: NumberFormatter.convertFromCentsToUnitsCurrency(
                                          widget.product.account.lastCost,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          const Divider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                fit: FlexFit.tight,

                                child: SizedBox(
                                  height: 90,
                                  child: TitleTextField(
                                    focusNode: focusNode,
                                    style: const TextStyle(fontWeight: .w600),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "";
                                      }

                                      final numberValue = int.tryParse(value) ?? 0;

                                      if (numberValue == 0) {
                                        return "Cantidad invalida";
                                      }

                                      return null;
                                    },
                                    titleTextAlign: TextAlign.center,
                                    centerTitle: true,
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

                                child: SizedBox(
                                  height: 90,
                                  child: TitleTextField(
                                    centerTitle: true,
                                    key: ValueKey(commercialProductResult.selectedPriceLevel),
                                    readOnly: commercialProductResult.selectedPriceLevel != 0,
                                    titleTextAlign: TextAlign.center,
                                    initialValue: price.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.w600),

                                    inputFormatters: [DecimalTextInputFormatter()],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final rowDecimal = double.tryParse(value) ?? 0.0;
                                      final rowInteger = NumberFormatter.convertFromDoubleToCents(rowDecimal);

                                      commercialProductResult.newPrice = int.tryParse(rowInteger.toString()) ?? 0;
                                      commercialProductResult.selectedPriceLevel = 0;
                                      setState(() {});
                                    },
                                    title: "Precio",
                                  ),
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

                          TextButton.icon(
                            onPressed: () {
                              final priceString = NumberFormatter.convertToMoneyLike(commercialProductResult.newPrice);
                              final text =
                                  "${product.name} \n${product.brandName} - ${product.unitName} \nPrecio: $priceString";
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Copiado: ${product.name} - $priceString"),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text("Copiar Info"),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Descuentos Disponibles",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 12),

                          AbsorbPointer(
                            absorbing:
                                commercialProductResult.newPrice !=
                                commercialProductResult.product.saleProfile.salePrice,
                            child: DropdownButtonFormField(
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
          height: 160,
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
                        if (product.saleProfile.salePrice == 0) {
                          DialogManager.showErrorDialog(context, "El producto no tiene precio de venta");
                          return;
                        }

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
