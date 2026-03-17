import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/cubit/write_product_sale_profile_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/dialogs/discount_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/widgets/discount_tile.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<ProductSaleProfileInDb?> showPriceEditorByProductId(
  BuildContext context,
  String productId,
) async {
  LoadingDialogManager.showLoadingDialog(context);
  try {
    final productRepo = context.read<ProductsRepository>();
    final product = await productRepo.getProductInBranchById(productId);
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
  late List<Discount> currentDiscounts;

  FocusNode priceFocus = FocusNode();
  FocusNode priceFocus2 = FocusNode();
  FocusNode priceFocus3 = FocusNode();

  bool hasLowerPrices = false;

  @override
  void initState() {
    super.initState();
    currentSalePrice = widget.product.saleProfile.salePrice;
    currentSalePrice2 = widget.product.saleProfile.salePrice2;
    currentSalePrice3 = widget.product.saleProfile.salePrice3;
    currentDiscounts = [...widget.product.saleProfile.discounts];
    Future(
      () {
        priceFocus.requestFocus();
      },
    );
  }

  void _saveProduct() {
    final updatedDto = UpdateProductSaleProfile(
      salePrice: currentSalePrice,
      salePrice2: currentSalePrice2,
      salePrice3: currentSalePrice3,
      discounts: currentDiscounts,
    );
    context.read<WriteProductSaleProfileCubit>().updateProfile(
      widget.product.id,
      updatedDto,
    );
  }

  @override
  Widget build(BuildContext context) {
    hasLowerPrices =
        [
          currentSalePrice,
          if (currentSalePrice2 > 0) currentSalePrice2,
          if (currentSalePrice3 > 0) currentSalePrice3,
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
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => _saveProduct(),
        },
        child: Focus(
          autofocus: true,
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
                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _saveProduct,
                            child: const Text(
                              "Guardar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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

                        const SizedBox(
                          height: 12,
                        ),

                        TitleTextField(
                          key: const Key("price1"),
                          title: "Precio de Venta (C\$ )",
                          focusNode: priceFocus,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
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

                          initialValue: NumberFormatter.convertFromCentsToDouble(
                            widget.product.saleProfile.salePrice,
                          ).toString(),

                          inputFormatters: [DoubleThousandsFormatter()],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TitleTextField(
                          key: const Key("price2"),
                          title: "Precio de Venta 2 (C\$ )",
                          focusNode: priceFocus2,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
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

                          initialValue: NumberFormatter.convertFromCentsToDouble(
                            widget.product.saleProfile.salePrice2,
                          ).toString(),

                          inputFormatters: [DoubleThousandsFormatter()],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TitleTextField(
                          key: const Key("price3"),
                          title: "Precio de Venta 3 (C\$ )",
                          focusNode: priceFocus3,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
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

                          initialValue: NumberFormatter.convertFromCentsToDouble(
                            widget.product.saleProfile.salePrice3,
                          ).toString(),

                          inputFormatters: [DoubleThousandsFormatter()],
                        ),

                        const Divider(),
                        Row(
                          children: [
                            const Text(
                              "Descuentos",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              child: const Text("Agregar Descuento"),
                              onPressed: () async {
                                final res = await showDiscountDialog(context);
                                if (res == null) return;

                                currentDiscounts.add(res);
                                setState(() {});
                              },
                            ),
                          ],
                        ),

                        _DiscountListViewContainer(
                          discounts: currentDiscounts,
                          salePrice: currentSalePrice,
                        ),
                      ],
                    ),
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
