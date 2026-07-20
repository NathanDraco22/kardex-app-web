import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../models/commercial_product_result.dart';
import 'commercial_product_unit_selector.dart';

Future<CommercialProductResult?> showCommercialProductDialogFromId(
  BuildContext context, {
  required String productId,
  SaleItem? previousSaleItem,
  int defaultPriceLevel = 1,
  String preferredUnitType = 'min',
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

      initialResult = CommercialProductResult(
        product: product,
        defaultPriceLevel: previousSaleItem.selectedPrice,
        preferredUnitType: preferredUnitType,
      )
        ..quantity = previousSaleItem.quantity
        ..selectedPriceLevel = previousSaleItem.selectedPrice
        ..newPrice = previousSaleItem.price
        ..selectedDiscount = appliedDiscount;
    }

    return await showCommercialProductDialog(
      context,
      product: product,
      commercialProductResult: initialResult,
      defaultPriceLevel: defaultPriceLevel,
      preferredUnitType: preferredUnitType,
    );
  } catch (e) {
    if (context.mounted) {
      LoadingDialogManager.closeLoadingDialog(context);
      DialogManager.showErrorDialog(context, "Error al obtener el producto: $e");
    }
    return null;
  }
}

Future<CommercialProductResult?> showCommercialProductDialog(
  BuildContext context, {
  required ProductInDbInBranch product,
  CommercialProductResult? commercialProductResult,
  int defaultPriceLevel = 1,
  String preferredUnitType = 'min',
}) async {
  return await showDialog<CommercialProductResult?>(
    barrierDismissible: false,
    context: context,
    builder: (context) => CommercialProductDialog(
      product: product,
      commercialProductResult: commercialProductResult,
      defaultPriceLevel: defaultPriceLevel,
      preferredUnitType: preferredUnitType,
    ),
  );
}

class CommercialProductDialog extends StatelessWidget {
  const CommercialProductDialog({
    super.key,
    required this.product,
    this.commercialProductResult,
    this.defaultPriceLevel = 1,
    this.preferredUnitType = 'min',
  });
  final ProductInDbInBranch product;
  final CommercialProductResult? commercialProductResult;
  final int defaultPriceLevel;
  final String preferredUnitType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: const BoxConstraints(maxWidth: 700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 650,
        height: 600,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _FormContent(
            product: product,
            commercialProductResult: commercialProductResult,
            defaultPriceLevel: defaultPriceLevel,
            preferredUnitType: preferredUnitType,
          ),
        ),
      ),
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({
    required this.product,
    this.commercialProductResult,
    this.defaultPriceLevel = 1,
    this.preferredUnitType = 'min',
  });

  final ProductInDbInBranch product;
  final CommercialProductResult? commercialProductResult;
  final int defaultPriceLevel;
  final String preferredUnitType;

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  late CommercialProductResult commercialProductResult;
  late Iterable<DropdownMenuItem<Discount>> discountsAvailable;
  FocusNode focusNode = FocusNode();
  FocusNode acceptFocusNode = FocusNode();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    if (widget.commercialProductResult != null) {
      commercialProductResult = widget.commercialProductResult!.copyWith();
    } else {
      commercialProductResult = CommercialProductResult(
        product: widget.product,
        defaultPriceLevel: widget.defaultPriceLevel,
        preferredUnitType: widget.preferredUnitType,
      );
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
    double price = NumberFormatter.convertFromCentsToDouble(
      commercialProductResult.newPrice * commercialProductResult.conversionFactor,
    );
    final subtotal = NumberFormatter.convertToMoneyLike(commercialProductResult.subTotal);
    final totalDiscount = NumberFormatter.convertToMoneyLike(commercialProductResult.totalDiscount);
    final total = NumberFormatter.convertToMoneyLike(commercialProductResult.total);

    final availableStock = widget.product.account.availableStock;
    final factor = commercialProductResult.conversionFactor;
    final unitName = commercialProductResult.selectedUnitName;
    final baseUnitName = widget.product.unitName;
    final stockStr = NumberFormatter.formatDisplayStock(availableStock, factor);
    final displayStock = "$stockStr $unitName";

    return Form(
      key: formKey,
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: ImageViewerWidget(
                  imageUrls: widget.product.image.isNotEmpty ? [widget.product.image] : [],
                  width: 90,
                  height: 90,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                widget.product.displayCode,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TitleLabel(
                    title: "Marca",
                    bigTitle: widget.product.brandName,
                  ),
                  TitleLabel(
                    title: "Unidad",
                    bigTitle: widget.product.unitName,
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 8),

                    SizedBox(
                      width: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CommercialProductUnitSelector(
                            result: commercialProductResult,
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 12),
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
                              DropdownMenuItem(
                                value: 4,
                                child: Text(
                                  "Precio 4 (${NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice4)})",
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
                                4: product.saleProfile.salePrice4,
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    Color? stockColor;

                                    if (commercialProductResult.selectedUnitIndex != 0) {
                                      stockColor = Colors.blue;
                                    }

                                    if (availableStock <= 0) {
                                      stockColor = Colors.red;
                                    }

                                    return TitleLabel(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      title: "Existencia",
                                      bigTitle: displayStock,
                                      bigTitleColor: stockColor,
                                    );
                                  },
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
                                          widget.product.account.averageCost * factor,
                                        ),
                                      ),
                                      TitleLabel(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        title: "Ult. C",
                                        bigTitle: NumberFormatter.convertFromCentsToUnitsCurrency(
                                          widget.product.account.lastCost * factor,
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
                                  height: 80,
                                  child: TitleTextField(
                                    focusNode: focusNode,

                                    onEditingComplete: () {
                                      FocusScope.of(context).requestFocus(acceptFocusNode);
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "";
                                      }

                                      final numberValue = int.tryParse(value) ?? 0;

                                      if (numberValue == 0) {
                                        return "Cantidad invalida";
                                      }

                                      final requestedUnits = numberValue * commercialProductResult.conversionFactor;
                                      if (requestedUnits > availableStock) {
                                        return "Supera la existencia ($availableStock $baseUnitName)";
                                      }

                                      return null;
                                    },
                                    titleTextAlign: TextAlign.center,
                                    initialValue: commercialProductResult.quantity.toString(),
                                    inputFormatters: [IntegerTextInputFormatter()],
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
                                  height: 80,
                                  child: TitleTextField(
                                    key: ValueKey(
                                      "${commercialProductResult.selectedPriceLevel}_${commercialProductResult.selectedUnitIndex}",
                                    ),
                                    readOnly: commercialProductResult.selectedPriceLevel != 0,
                                    titleTextAlign: TextAlign.center,
                                    initialValue: price.toString(),
                                    inputFormatters: [DecimalTextInputFormatter()],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final rowDecimal = double.tryParse(value) ?? 0.0;
                                      final rowInteger = NumberFormatter.convertFromDoubleToCents(rowDecimal);

                                      // Guardar el precio convertido a unidad base
                                      commercialProductResult.newPrice =
                                          (rowInteger / commercialProductResult.conversionFactor).round();
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
                              initialValue: commercialProductResult.selectedDiscount,
                              items: discountsAvailable.toList(),
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    commercialProductResult.selectedDiscount = null;
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                              onChanged: (value) {
                                commercialProductResult.selectedDiscount = value;
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
                      focusNode: acceptFocusNode,
                      onPressed: () {
                        if (commercialProductResult.newPrice == 0) {
                          DialogManager.showErrorDialog(context, "El producto tiene un precio 0, no se puede vender");
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
