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

import 'package:kardex_app_front/src/cubits/write_product_account/write_product_account_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/add_product_inventory_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/substract_product_inventory_dialog.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

Future<ProductInDbInBranch?> showProductInventoryEditor(
  BuildContext context,
  ProductInDbInBranch product,
) async {
  final saleProfilesRepository = context.read<ProductSaleProfilesRepository>();
  final productAccountsRepository = context.read<ProductAccountsRepository>();

  return await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WriteProductSaleProfileCubit(
              profilesRepository: saleProfilesRepository,
            ),
          ),
          BlocProvider(
            create: (context) => WriteProductAccountCubit(
              productAccountsRepository: productAccountsRepository,
            ),
          ),
        ],
        child: ProductInventoryEditorScreen(initialProduct: product),
      ),
    ),
  );
}

class ProductInventoryEditorScreen extends StatelessWidget {
  const ProductInventoryEditorScreen({super.key, required this.initialProduct});

  final ProductInDbInBranch initialProduct;

  @override
  Widget build(BuildContext context) {
    return _RootScaffold(initialProduct);
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold(this.initialProduct);

  final ProductInDbInBranch initialProduct;

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  late ProductInDbInBranch currentProduct;

  late int currentSalePrice;
  late int currentSalePrice2;
  late int currentSalePrice3;
  late List<Discount> currentDiscounts;

  FocusNode priceFocus = FocusNode();
  FocusNode priceFocus2 = FocusNode();
  FocusNode priceFocus3 = FocusNode();

  bool hasLowerPrices = false;
  bool stockWasModified = false;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.initialProduct;
    currentSalePrice = currentProduct.saleProfile.salePrice;
    currentSalePrice2 = currentProduct.saleProfile.salePrice2;
    currentSalePrice3 = currentProduct.saleProfile.salePrice3;
    currentDiscounts = [...currentProduct.saleProfile.discounts];
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
      currentProduct.id,
      updatedDto,
    );
  }

  @override
  Widget build(BuildContext context) {
    hasLowerPrices = [
      currentSalePrice,
      if (currentSalePrice2 > 0) currentSalePrice2,
      if (currentSalePrice3 > 0) currentSalePrice3,
    ].any(
      (price) => price < currentProduct.account.averageCost,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final res = await DialogManager.confirmActionDialog(context, "Deseas salir sin guardar los cambios del precio?");

        if (res != true) return;

        if (!context.mounted) return;

        // If stock was modified, we return the modified product even though price weren't saved
        if (stockWasModified) {
          Navigator.pop(context, currentProduct);
        } else {
          Navigator.pop(context);
        }
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => _saveProduct(),
        },
        child: Focus(
          autofocus: true,
          child: MultiBlocListener(
            listeners: [
              BlocListener<WriteProductSaleProfileCubit, WriteProductSaleProfileState>(
                listener: (context, state) async {
                  if (state is WriteProductSaleProfileInProgress) {
                    LoadingDialogManager.showLoadingDialog(context);
                  }

                  if (state is WriteProductSaleProfileSuccess) {
                    LoadingDialogManager.closeLoadingDialog(context);
                    await DialogManager.showInfoDialog(context, "Precios guardados exitosamente");
                    if (!context.mounted) return;
                    currentProduct = currentProduct.copyWith(saleProfile: state.profile);
                    Navigator.pop(context, currentProduct);
                  }
                  
                  if (state is WriteProductSaleProfileError) {
                    LoadingDialogManager.closeLoadingDialog(context);
                    await DialogManager.showErrorDialog(context, state.error);
                  }
                },
              ),
              BlocListener<WriteProductAccountCubit, WriteProductAccountState>(
                listener: (context, state) async {
                  if (state is WriteProductAccountInProgress) {
                    LoadingDialogManager.showLoadingDialog(context);
                  }

                  if (state is WriteProductAccountSuccess) {
                    LoadingDialogManager.closeLoadingDialog(context);
                    await DialogManager.showInfoDialog(context, "Inventario actualizado exitosamente");
                    if (!context.mounted) return;
                    
                    setState(() {
                      currentProduct = currentProduct.copyWith(account: state.account);
                      stockWasModified = true;
                    });
                  }
                  
                  if (state is WriteProductAccountFailure) {
                    LoadingDialogManager.closeLoadingDialog(context);
                    await DialogManager.showErrorDialog(context, state.message);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Editor de Inventario y Precios"),
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
                              "Guardar Precios",
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
                          currentProduct.name,
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
                              currentProduct.brandName,
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
                              currentProduct.unitName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TitleLabel(
                                  title: "Costo Promedio",
                                  bigTitle: NumberFormatter.convertToMoneyLike(
                                    currentProduct.account.averageCost,
                                  ),
                                ),
                              ),
                              const VerticalDivider(width: 40),
                              Expanded(
                                child: TitleLabel(
                                  title: "Existencia",
                                  bigTitle: currentProduct.account.currentStock.toString(),
                                  bigTitleColor: currentProduct.account.currentStock > 0 ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green.shade100,
                                  foregroundColor: Colors.green.shade900,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text("Agregar al inventario"),
                                onPressed: () async {
                                  final authState = context.read<AuthCubit>().state;
                                  if (authState is! Authenticated) return;
                                  final branchId = authState.branch.id;
                                  
                                  final res = await showAddProductInventoryDialog(
                                    context,
                                    currentAverageCost: currentProduct.account.averageCost,
                                  );

                                  if (res == null) return;
                                  if (!context.mounted) return;

                                  context.read<WriteProductAccountCubit>().addProductAccount(
                                    currentProduct.id,
                                    branchId,
                                    currentStock: res['currentStock']!,
                                    averageCost: res['averageCost']!,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.red.shade100,
                                  foregroundColor: Colors.red.shade900,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text("Restar al inventario"),
                                onPressed: () async {
                                  final authState = context.read<AuthCubit>().state;
                                  if (authState is! Authenticated) return;
                                  final branchId = authState.branch.id;

                                  final res = await showSubstractProductInventoryDialog(
                                    context,
                                  );

                                  if (res == null) return;
                                  if (!context.mounted) return;

                                  context.read<WriteProductAccountCubit>().substractProductAccount(
                                    currentProduct.id,
                                    branchId,
                                    currentStock: res,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
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
                            currentProduct.saleProfile.salePrice,
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
                            currentProduct.saleProfile.salePrice2,
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
                            currentProduct.saleProfile.salePrice3,
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
