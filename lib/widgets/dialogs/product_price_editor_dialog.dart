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
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
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

  late final TextEditingController basePrice1Controller;
  late final TextEditingController basePrice2Controller;
  late final TextEditingController basePrice3Controller;
  late final TextEditingController basePrice4Controller;

  late final TextEditingController extraPrice1Controller;
  late final TextEditingController extraPrice2Controller;
  late final TextEditingController extraPrice3Controller;
  late final TextEditingController extraPrice4Controller;

  final FocusNode priceFocus = FocusNode();
  final FocusNode priceFocus2 = FocusNode();
  final FocusNode priceFocus3 = FocusNode();
  final FocusNode priceFocus4 = FocusNode();

  final FocusNode extraPriceFocus = FocusNode();
  final FocusNode extraPriceFocus2 = FocusNode();
  final FocusNode extraPriceFocus3 = FocusNode();
  final FocusNode extraPriceFocus4 = FocusNode();

  bool _isSyncing = false;
  bool hasLowerPrices = false;

  String _centsToText(int cents) => (cents / 100).toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    currentSalePrice = widget.product.saleProfile.salePrice;
    currentSalePrice2 = widget.product.saleProfile.salePrice2;
    currentSalePrice3 = widget.product.saleProfile.salePrice3;
    currentSalePrice4 = widget.product.saleProfile.salePrice4;
    currentDiscounts = [...widget.product.saleProfile.discounts];

    if (widget.product.extraUnits.isNotEmpty) {
      if (widget.product.defaultUnitIndex > 0 &&
          widget.product.defaultUnitIndex - 1 < widget.product.extraUnits.length) {
        selectedExtraUnit = widget.product.extraUnits[widget.product.defaultUnitIndex - 1];
      } else if (widget.product.wholesaleUnitIndex > 0 &&
          widget.product.wholesaleUnitIndex - 1 < widget.product.extraUnits.length) {
        selectedExtraUnit = widget.product.extraUnits[widget.product.wholesaleUnitIndex - 1];
      } else {
        selectedExtraUnit = widget.product.extraUnits.first;
      }
    }

    final factor = selectedExtraUnit?.conversionFactor ?? 1;

    basePrice1Controller = TextEditingController(text: _centsToText(currentSalePrice));
    basePrice2Controller = TextEditingController(text: _centsToText(currentSalePrice2));
    basePrice3Controller = TextEditingController(text: _centsToText(currentSalePrice3));
    basePrice4Controller = TextEditingController(text: _centsToText(currentSalePrice4));

    extraPrice1Controller = TextEditingController(text: _centsToText(currentSalePrice * factor));
    extraPrice2Controller = TextEditingController(text: _centsToText(currentSalePrice2 * factor));
    extraPrice3Controller = TextEditingController(text: _centsToText(currentSalePrice3 * factor));
    extraPrice4Controller = TextEditingController(text: _centsToText(currentSalePrice4 * factor));

    Future(
      () {
        priceFocus.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    basePrice1Controller.dispose();
    basePrice2Controller.dispose();
    basePrice3Controller.dispose();
    basePrice4Controller.dispose();

    extraPrice1Controller.dispose();
    extraPrice2Controller.dispose();
    extraPrice3Controller.dispose();
    extraPrice4Controller.dispose();

    priceFocus.dispose();
    priceFocus2.dispose();
    priceFocus3.dispose();
    priceFocus4.dispose();

    extraPriceFocus.dispose();
    extraPriceFocus2.dispose();
    extraPriceFocus3.dispose();
    extraPriceFocus4.dispose();

    super.dispose();
  }

  void _updateAllExtraControllers() {
    final factor = selectedExtraUnit?.conversionFactor ?? 1;
    _isSyncing = true;
    try {
      extraPrice1Controller.text = _centsToText(currentSalePrice * factor);
      extraPrice2Controller.text = _centsToText(currentSalePrice2 * factor);
      extraPrice3Controller.text = _centsToText(currentSalePrice3 * factor);
      extraPrice4Controller.text = _centsToText(currentSalePrice4 * factor);
    } finally {
      _isSyncing = false;
    }
  }

  void _onBasePriceChanged(int level, String value) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final formattedValue = value.replaceAll(",", "");
      final valDouble = double.tryParse(formattedValue) ?? 0.0;
      final cents = (valDouble * 100).round();

      final factor = selectedExtraUnit?.conversionFactor ?? 1;
      final extraCents = cents * factor;
      final extraText = _centsToText(extraCents);

      switch (level) {
        case 1:
          currentSalePrice = cents;
          extraPrice1Controller.text = extraText;
          break;
        case 2:
          currentSalePrice2 = cents;
          extraPrice2Controller.text = extraText;
          break;
        case 3:
          currentSalePrice3 = cents;
          extraPrice3Controller.text = extraText;
          break;
        case 4:
          currentSalePrice4 = cents;
          extraPrice4Controller.text = extraText;
          break;
      }
      setState(() {});
    } finally {
      _isSyncing = false;
    }
  }

  void _onExtraPriceChanged(int level, String value) {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      final formattedValue = value.replaceAll(",", "");
      final extraDouble = double.tryParse(formattedValue) ?? 0.0;
      final factor = selectedExtraUnit?.conversionFactor ?? 1;

      final baseCents = factor > 0
          ? ((extraDouble * 100) / factor).round()
          : (extraDouble * 100).round();
      final baseText = _centsToText(baseCents);

      switch (level) {
        case 1:
          currentSalePrice = baseCents;
          basePrice1Controller.text = baseText;
          break;
        case 2:
          currentSalePrice2 = baseCents;
          basePrice2Controller.text = baseText;
          break;
        case 3:
          currentSalePrice3 = baseCents;
          basePrice3Controller.text = baseText;
          break;
        case 4:
          currentSalePrice4 = baseCents;
          basePrice4Controller.text = baseText;
          break;
      }
      setState(() {});
    } finally {
      _isSyncing = false;
    }
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

  Widget _buildPriceInput({
    required String keyStr,
    required String title,
    required FocusNode baseFocusNode,
    required TextEditingController baseController,
    required ValueChanged<String> onBaseChanged,
    FocusNode? extraFocusNode,
    TextEditingController? extraController,
    ValueChanged<String>? onExtraChanged,
  }) {
    final baseInputField = TitleTextField(
      key: Key(keyStr),
      title: title,
      focusNode: baseFocusNode,
      keyboardType: TextInputType.number,
      controller: baseController,
      onChanged: onBaseChanged,
      textInputAction: TextInputAction.next,
      inputFormatters: [DoubleThousandsFormatter()],
    );

    if (widget.product.extraUnits.isEmpty || selectedExtraUnit == null || extraController == null) {
      return baseInputField;
    }

    final extraUnit = selectedExtraUnit!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: baseInputField,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TitleTextField(
            key: Key("${keyStr}_extra"),
            title: "Por ${extraUnit.name} (C\$ ):",
            focusNode: extraFocusNode,
            keyboardType: TextInputType.number,
            controller: extraController,
            onChanged: onExtraChanged,
            textInputAction: TextInputAction.next,
            inputFormatters: [DoubleThousandsFormatter()],
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

                      Builder(
                        builder: (context) {
                          final factor = selectedExtraUnit?.conversionFactor ?? 1;
                          final hasExtra = selectedExtraUnit != null && factor > 1;
                          final unitLabel = hasExtra ? selectedExtraUnit!.name : widget.product.unitName;

                          Widget buildCostItem(String label, int baseCostInCents) {
                            if (!hasExtra) {
                              return TitleLabel(
                                title: label,
                                bigTitle: NumberFormatter.convertToMoneyLike(baseCostInCents),
                              );
                            }
                            final extraCostInCents = baseCostInCents * factor;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$label ($unitLabel)",
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  NumberFormatter.convertToMoneyLike(extraCostInCents),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "Base: ${NumberFormatter.convertToMoneyLike(baseCostInCents)}",
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            );
                          }

                          return SizedBox(
                            height: hasExtra ? 54 : 40,
                            child: Row(
                              children: [
                                Expanded(
                                  child: buildCostItem("Costo", widget.product.account.averageCost),
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  child: buildCostItem("Ultima Compra", widget.product.account.lastCost),
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  child: buildCostItem("Costo Maximo", widget.product.account.maximumCost),
                                ),
                              ],
                            ),
                          );
                        },
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
                                      _updateAllExtraControllers();
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

                          final factor = selectedExtraUnit?.conversionFactor ?? 1;
                          final hasExtra = selectedExtraUnit != null && factor > 1;
                          final extraSuggestedCents = suggestedPriceInCents * factor;
                          final extraCostInCents = costInCents * factor;

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
                                        hasExtra
                                            ? "Precio Sugerido (+${profitMargin.toStringAsFixed(profitMargin.truncateToDouble() == profitMargin ? 0 : 1)}%): ${NumberFormatter.convertToMoneyLike(extraSuggestedCents)} por ${selectedExtraUnit!.name}"
                                            : "Precio Sugerido (+${profitMargin.toStringAsFixed(profitMargin.truncateToDouble() == profitMargin ? 0 : 1)}%): ${NumberFormatter.convertToMoneyLike(suggestedPriceInCents)}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      Text(
                                        hasExtra
                                            ? "Calculado sobre costo: ${NumberFormatter.convertToMoneyLike(extraCostInCents)} (${NumberFormatter.convertToMoneyLike(costInCents)} por ${widget.product.unitName})"
                                            : "Calculado sobre costo (${NumberFormatter.convertToMoneyLike(costInCents)})",
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
                                    basePrice1Controller.text = suggestedDouble.toString();
                                    extraPrice1Controller.text = _centsToText(extraSuggestedCents);
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
                        keyStr: "price1",
                        title: "Precio de Venta (C\$ )",
                        baseFocusNode: priceFocus,
                        baseController: basePrice1Controller,
                        onBaseChanged: (val) => _onBasePriceChanged(1, val),
                        extraFocusNode: extraPriceFocus,
                        extraController: extraPrice1Controller,
                        onExtraChanged: (val) => _onExtraPriceChanged(1, val),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildPriceInput(
                        keyStr: "price2",
                        title: "Precio de Venta 2 (C\$ )",
                        baseFocusNode: priceFocus2,
                        baseController: basePrice2Controller,
                        onBaseChanged: (val) => _onBasePriceChanged(2, val),
                        extraFocusNode: extraPriceFocus2,
                        extraController: extraPrice2Controller,
                        onExtraChanged: (val) => _onExtraPriceChanged(2, val),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildPriceInput(
                        keyStr: "price3",
                        title: "Precio de Venta 3 (C\$ )",
                        baseFocusNode: priceFocus3,
                        baseController: basePrice3Controller,
                        onBaseChanged: (val) => _onBasePriceChanged(3, val),
                        extraFocusNode: extraPriceFocus3,
                        extraController: extraPrice3Controller,
                        onExtraChanged: (val) => _onExtraPriceChanged(3, val),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildPriceInput(
                        keyStr: "price4",
                        title: "Precio de Venta 4 (C\$ )",
                        baseFocusNode: priceFocus4,
                        baseController: basePrice4Controller,
                        onBaseChanged: (val) => _onBasePriceChanged(4, val),
                        extraFocusNode: extraPriceFocus4,
                        extraController: extraPrice4Controller,
                        onExtraChanged: (val) => _onExtraPriceChanged(4, val),
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
