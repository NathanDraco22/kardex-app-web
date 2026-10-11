import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/cubit/write_product_sale_profile_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/dialogs/discount_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/widgets/discount_tile.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<ProductSaleProfileInDb?> showPriceEditorByProductId(
  BuildContext context,
  String productId,
) async {
  LoadingDialogManager.showLoadingDialog(context);
  try {
    final branchId = getIt<AuthCubit>().currentBranchId;
    final productRepo = context.read<ProductsRepository>();
    final product = await productRepo.getProductInBranchById(productId, branchId);
    if (!context.mounted) return null;
    LoadingDialogManager.closeLoadingDialog(context);

    return await showProductPriceEditor(context, product);
  } catch (e) {
    if (!context.mounted) return null;
    LoadingDialogManager.closeLoadingDialog(context);
    await DialogManager.showErrorDialog(context, e.toString());
    return null;
  }
}

Future<ProductSaleProfileInDb?> showProductPriceEditor(
  BuildContext context,
  ProductInDbInBranch product,
) async {
  final repository = context.read<ProductSaleProfilesRepository>();

  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => WriteProductSaleProfileCubit(
          profilesRepository: repository,
        ),
        child: ProductPriceEditorScreen(product: product),
      ),
    ),
  );
}

class ProductPriceEditorScreen extends StatelessWidget {
  const ProductPriceEditorScreen({super.key, required this.product});

  final ProductInDbInBranch product;

  @override
  Widget build(BuildContext context) {
    return _RootScaffold(product);
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold(this.product);

  final ProductInDbInBranch product;

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  late int currentSalePrice;
  late int currentSalePrice2;
  late int currentSalePrice3;
  late int currentSalePrice4;
  late List<Discount> currentDiscounts;
  ExtraUnit? selectedExtraUnit;

  late final TextEditingController price1Controller;

  FocusNode priceFocus = FocusNode();
  FocusNode priceFocus2 = FocusNode();
  FocusNode priceFocus3 = FocusNode();
  FocusNode priceFocus4 = FocusNode();

  bool hasLowerPrices = false;

  @override
  void initState() {
    super.initState();
    currentSalePrice = widget.product.saleProfile.salePrice;
    currentSalePrice2 = widget.product.saleProfile.salePrice2;
    currentSalePrice3 = widget.product.saleProfile.salePrice3;
    currentSalePrice4 = widget.product.saleProfile.salePrice4;
    currentDiscounts = [...widget.product.saleProfile.discounts];
    price1Controller = TextEditingController(
      text: NumberFormatter.convertFromCentsToDouble(
        widget.product.saleProfile.salePrice,
      ).toString(),
    );
    if (widget.product.extraUnits.isNotEmpty) {
      selectedExtraUnit = widget.product.extraUnits.first;
    }
    Future(
      () {
        priceFocus.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    price1Controller.dispose();
    super.dispose();
  }

  void _saveProduct() {
    final updatedDto = UpdateProductSaleProfile(
      salePrice: currentSalePrice,
      salePrice2: currentSalePrice2,
      salePrice3: currentSalePrice3,
      salePrice4: currentSalePrice4,
      discounts: currentDiscounts,
    );
    final branchId = getIt<AuthCubit>().currentBranchId;
    context.read<WriteProductSaleProfileCubit>().updateProfile(
      branchId,
      widget.product.id,
      updatedDto,
    );
  }

  Widget _buildPriceInput(
    String keyStr,
    String title,
    FocusNode focusNode,
    int currentValue,
    String initialValue,
    ValueChanged<String> onChanged, {
    TextEditingController? controller,
  }) {
    final inputField = TitleTextField(
      key: Key(keyStr),
      title: title,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      controller: controller,
      onChanged: onChanged,
      initialValue: controller == null ? initialValue : null,
      textInputAction: TextInputAction.next,
      inputFormatters: [DoubleThousandsFormatter()],
    );

    if (widget.product.extraUnits.isEmpty || selectedExtraUnit == null) {
      return inputField;
    }

    final extraUnit = selectedExtraUnit!;
    final calculatedValue = currentValue * extraUnit.conversionFactor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 3,
          child: inputField,
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Por ${extraUnit.name}:",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormatter.convertToMoneyLike(calculatedValue),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    hasLowerPrices =
        [
          currentSalePrice,
          if (currentSalePrice2 > 0) currentSalePrice2,
          if (currentSalePrice3 > 0) currentSalePrice3,
          if (currentSalePrice4 > 0) currentSalePrice4,
        ].any(
          (price) => price < widget.product.account.averageCost,
        );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final res = await DialogManager.confirmActionDialog(context, "Deseas salir sin guardar?");

        if (res != true) return;

        if (!context.mounted) return;

        Navigator.pop(context);
      },
      child: ShortcutContainer(
        child: BlocListener<WriteProductSaleProfileCubit, WriteProductSaleProfileState>(
          listener: (context, state) async {
            if (state is WriteProductSaleProfileInProgress) {
              LoadingDialogManager.showLoadingDialog(context);
            }

            if (state is WriteProductSaleProfileSuccess) {
              LoadingDialogManager.closeLoadingDialog(context);
              await DialogManager.showInfoDialog(context, "Guardado exitosamente");
              if (!context.mounted) return;
              Navigator.pop(context, state.profile);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Configuración de Precios"),
            ),
            bottomNavigationBar: BottomAppBar(
              height: 48,
              color: Colors.grey.shade200,
              elevation: 2.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: ElevatedCtrlButton(
                        hotKey: "G",
                        onPressed: _saveProduct,
                        label: "Guardar",
                        icon: Icons.save,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    children: [
                      Center(
                        child: ImageViewerWidget(
                          imageUrls: widget.product.image.isNotEmpty ? [widget.product.image] : [],
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.product.brandName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Text(
                            widget.product.unitName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            TitleLabel(
                              title: "Costo",
                              bigTitle: NumberFormatter.convertToMoneyLike(
                                widget.product.account.averageCost,
                              ),
                            ),
                            const VerticalDivider(),

                            TitleLabel(
                              title: "Ultima Compra",
                              bigTitle: NumberFormatter.convertToMoneyLike(
                                widget.product.account.lastCost,
                              ),
                            ),
                            const VerticalDivider(),

                            TitleLabel(
                              title: "Costo Maximo",
                              bigTitle: NumberFormatter.convertToMoneyLike(
                                widget.product.account.maximumCost,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      SizedBox(
                        height: 30,
                        child: Builder(
                          builder: (context) {
                            if (hasLowerPrices) {
                              return ListTile(
                                leading: Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber.shade700,
                                ),
                                title: Text(
                                  "Precio de Venta menor al costo",
                                  style: TextStyle(
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      if (widget.product.extraUnits.isNotEmpty && selectedExtraUnit != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Precio Base para:",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.product.unitName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<ExtraUnit>(
                                decoration: const InputDecoration(
                                  labelText: 'Calcular para la unidad:',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                initialValue: selectedExtraUnit,
                                items: widget.product.extraUnits.map((extra) {
                                  return DropdownMenuItem<ExtraUnit>(
                                    value: extra,
                                    child: Text('${extra.name} (x${extra.conversionFactor})'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedExtraUnit = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],

                      Builder(
                        builder: (context) {
                          final appSettings = getIt<AppSettingsCubit>();
                          if (!appSettings.useDefaultProfitMargin) {
                            return const SizedBox.shrink();
                          }
                          final profitMargin = appSettings.defaultProfitMargin;
                          final costInCents = widget.product.account.averageCost > 0
                              ? widget.product.account.averageCost
                              : widget.product.account.lastCost;
                          if (costInCents <= 0) {
                            return const SizedBox.shrink();
                          }
                          final suggestedPriceInCents = (costInCents * (1 + profitMargin / 100)).round();
                          final suggestedDouble = NumberFormatter.convertFromCentsToDouble(suggestedPriceInCents);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 20, color: Colors.blue.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Precio Sugerido (+${profitMargin.toStringAsFixed(profitMargin.truncateToDouble() == profitMargin ? 0 : 1)}%): ${NumberFormatter.convertToMoneyLike(suggestedPriceInCents)}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      Text(
                                        "Calculado sobre costo (${NumberFormatter.convertToMoneyLike(costInCents)})",
                                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    textStyle: const TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    currentSalePrice = suggestedPriceInCents;
                                    price1Controller.text = suggestedDouble.toString();
                                    setState(() {});
                                  },
                                  child: const Text("Usar Precio Sugerido", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      _buildPriceInput(
                        "price1",
                        "Precio de Venta (C\$ )",
                        priceFocus,
                        currentSalePrice,
                        NumberFormatter.convertFromCentsToDouble(
                          widget.product.saleProfile.salePrice,
                        ).toString(),
                        (value) {
                          if (value.isEmpty) {
                            currentSalePrice = 0;
                            setState(() {});
                            return;
                          }
                          final formattedValue = value.replaceAll(",", "");
                          final cents = ((double.tryParse(formattedValue) ?? 0) * 100).round();
                          currentSalePrice = cents;
                          setState(() {});
                        },
                        controller: price1Controller,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildPriceInput(
                        "price2",
                        "Precio de Venta 2 (C\$ )",
                        priceFocus2,
                        currentSalePrice2,
                        NumberFormatter.convertFromCentsToDouble(
                          widget.product.saleProfile.salePrice2,
                        ).toString(),
                        (value) {
                          if (value.isEmpty) {
                            currentSalePrice2 = 0;
                            setState(() {});
                            return;
                          }
                          final formattedValue = value.replaceAll(",", "");
                          final cents = ((double.tryParse(formattedValue) ?? 0) * 100).round();
                          currentSalePrice2 = cents;
                          setState(() {});
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildPriceInput(
                        "price3",
                        "Precio de Venta 3 (C\$ )",
                        priceFocus3,
                        currentSalePrice3,
                        NumberFormatter.convertFromCentsToDouble(
                          widget.product.saleProfile.salePrice3,
                        ).toString(),
                        (value) {
                          if (value.isEmpty) {
                            currentSalePrice3 = 0;
                            setState(() {});
                            return;
                          }
                          final formattedValue = value.replaceAll(",", "");
                          final cents = ((double.tryParse(formattedValue) ?? 0) * 100).round();
                          currentSalePrice3 = cents;
                          setState(() {});
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildPriceInput(
                        "price4",
                        "Precio de Venta 4 (C\$ )",
                        priceFocus4,
                        currentSalePrice4,
                        NumberFormatter.convertFromCentsToDouble(
                          widget.product.saleProfile.salePrice4,
                        ).toString(),
                        (value) {
                          if (value.isEmpty) {
                            currentSalePrice4 = 0;
                            setState(() {});
                            return;
                          }
                          final formattedValue = value.replaceAll(",", "");
                          final cents = ((double.tryParse(formattedValue) ?? 0) * 100).round();
                          currentSalePrice4 = cents;
                          setState(() {});
                        },
                      ),

                      const Divider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountListViewContainer extends StatefulWidget {
  const _DiscountListViewContainer({
    required this.discounts,
    required this.salePrice,
  });

  final List<Discount> discounts;
  final int salePrice;

  @override
  State<_DiscountListViewContainer> createState() => _DiscountListViewContainerState();
}

class _DiscountListViewContainerState extends State<_DiscountListViewContainer> {
  @override
  Widget build(BuildContext context) {
    final discounts = widget.discounts;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
        ),
      ),
      height: 200,
      child: ListView.separated(
        key: UniqueKey(),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: discounts.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 4.0);
        },
        itemBuilder: (context, index) {
          final currentDiscount = discounts[index];
          final currentPrice = widget.salePrice;
          final discountAmount = ((currentPrice * currentDiscount.percentValue) / 100).round();
          final discountTotal = currentPrice - discountAmount;
          return DiscountTile(
            name: currentDiscount.name,
            percentValue: currentDiscount.percentValue,
            amountValue: discountAmount,
            totalValue: discountTotal,
            onEditPressed: () async {
              final res = await showDiscountDialog(context, discount: currentDiscount);
              if (res == null) return;

              discounts[index] = res;
              setState(() {});
            },
            onDeletedPressed: () async {
              final res = await DialogManager.confirmActionDialog(context, "Eliminar descuento?");
              if (res != true) return;
              discounts.removeAt(index);
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
