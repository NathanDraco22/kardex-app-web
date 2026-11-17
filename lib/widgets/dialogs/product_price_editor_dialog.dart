import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/cubit/write_product_sale_profile_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/dialogs/discount_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/widgets/discount_tile.dart';
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
  late final PriceLevelSyncController priceController;
  late final TextEditingController _referenceCostController;
  late List<Discount> currentDiscounts;

  bool hasLowerPrices = false;

  @override
  void initState() {
    super.initState();
    final saleProfile = widget.product.saleProfile;

    priceController = PriceLevelSyncController(
      initialPrices: [
        saleProfile.salePrice,
        saleProfile.salePrice2,
        saleProfile.salePrice3,
        saleProfile.salePrice4,
      ],
      extraUnits: widget.product.extraUnits,
      defaultUnitIndex: widget.product.defaultUnitIndex,
      wholesaleUnitIndex: widget.product.wholesaleUnitIndex,
    );
    final initialRefCost = widget.product.account.averageCost;
    _referenceCostController = TextEditingController(
      text: initialRefCost > 0
          ? NumberFormatter.convertFromCentsToDouble(initialRefCost).toStringAsFixed(2)
          : '',
    );
    currentDiscounts = [...saleProfile.discounts];

    Future(
      () {
        priceController.baseFocusNodes.first.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    _referenceCostController.dispose();
    super.dispose();
  }

  int get _effectiveReferenceCostCents {
    if (widget.product.tracksInventory) {
      return widget.product.account.averageCost;
    }
    final parsed = double.tryParse(_referenceCostController.text.trim().replaceAll(',', '')) ?? 0.0;
    if (parsed < 0) return 0;
    return NumberFormatter.convertFromDoubleToCents(parsed);
  }

  Future<void> _saveProduct() async {
    final branchId = getIt<AuthCubit>().currentBranchId;
    if (!widget.product.tracksInventory) {
      final newRefCost = _effectiveReferenceCostCents;
      if (newRefCost != widget.product.account.averageCost) {
        try {
          await context.read<ProductAccountsRepository>().updateProductAccount(
            widget.product.id,
            branchId,
            averageCost: newRefCost,
          );
        } catch (e) {
          if (!mounted) return;
          await DialogManager.showErrorDialog(context, "Error al actualizar costo de referencia: $e");
          return;
        }
      }
    }

    if (!mounted) return;
    final prices = priceController.prices;
    final updatedDto = UpdateProductSaleProfile(
      salePrice: prices[0],
      salePrice2: prices[1],
      salePrice3: prices[2],
      salePrice4: prices[3],
      discounts: currentDiscounts,
    );
    context.read<WriteProductSaleProfileCubit>().updateProfile(
      branchId,
      widget.product.id,
      updatedDto,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPrices = priceController.prices;
    final effectiveCost = _effectiveReferenceCostCents;
    hasLowerPrices =
        [
          currentPrices[0],
          if (currentPrices[1] > 0) currentPrices[1],
          if (currentPrices[2] > 0) currentPrices[2],
          if (currentPrices[3] > 0) currentPrices[3],
        ].any(
          (price) => effectiveCost > 0 && price < effectiveCost,
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
                      if (!widget.product.tracksInventory) ...[
                        Center(
                          child: ProductTypeBadge(productType: widget.product.productType),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                          if (widget.product.brandName.isNotEmpty) ...[
                            Text(
                              widget.product.brandName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 12),
                          ],

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

                      if (widget.product.tracksInventory)
                        UnitCostComparison(
                          items: [
                            UnitCostItem(
                              label: "Costo",
                              baseCostInCents: widget.product.account.averageCost,
                            ),
                            UnitCostItem(
                              label: "Última Compra",
                              baseCostInCents: widget.product.account.lastCost,
                            ),
                            UnitCostItem(
                              label: "Costo Máximo",
                              baseCostInCents: widget.product.account.maximumCost,
                            ),
                          ],
                          baseUnitName: widget.product.unitName,
                          selectedUnitName: priceController.selectedUnit?.name ?? widget.product.unitName,
                          selectedUnitFactor: priceController.factor,
                        )
                      else
                        TitleTextField(
                          title: "Costo de referencia (opcional, ${NumberFormatter.currencySymbol})",
                          decoration: const InputDecoration(hintText: "0.00"),
                          controller: _referenceCostController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [const DecimalTextInputFormatter()],
                          onChanged: (_) => setState(() {}),
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
                                  "Precio Venta menor al costo",
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

                      if (priceController.hasExtraUnit) ...[
                        const SizedBox(height: 12),
                        PriceUnitSelector(
                          baseUnitName: widget.product.unitName,
                          extraUnits: priceController.extraUnits,
                          selectedUnit: priceController.selectedUnit,
                          onChanged: (unit) {
                            setState(() {
                              priceController.selectUnit(unit);
                            });
                          },
                        ),
                      ],

                      Builder(
                        builder: (context) {
                          final appSettings = getIt<AppSettingsCubit>();
                          if (!appSettings.useDefaultProfitMargin) {
                            return const SizedBox.shrink();
                          }
                          final costInCents = _effectiveReferenceCostCents > 0
                              ? _effectiveReferenceCostCents
                              : widget.product.account.lastCost;

                          return SuggestedPriceCard(
                            costInCents: costInCents,
                            profitMargin: appSettings.defaultProfitMargin,
                            baseUnitName: widget.product.unitName,
                            selectedUnitName: priceController.selectedUnit?.name,
                            selectedUnitFactor: priceController.factor,
                            onApplySuggested: (baseCents) {
                              setState(() {
                                priceController.applySuggestedBasePrice(baseCents);
                              });
                            },
                          );
                        },
                      ),

                      PriceLevelsSection(
                        controller: priceController,
                        onChanged: () => setState(() {}),
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
