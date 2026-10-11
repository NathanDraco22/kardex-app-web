import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/cubit/write_product_sale_profile_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import 'package:kardex_app_front/src/cubits/write_product_account/write_product_account_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/add_product_inventory_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/substract_product_inventory_dialog.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/write_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/dialogs/create_product_dialog.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_cubit.dart';

Future<ProductInDbInBranch?> showProductInventoryEditor(
  BuildContext context,
  ProductInDbInBranch product,
) async {
  final saleProfilesRepository = context.read<ProductSaleProfilesRepository>();
  final productAccountsRepository = context.read<ProductAccountsRepository>();
  final productsRepository = context.read<ProductsRepository>();

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
          BlocProvider(
            create: (context) => WriteProductCubit(productsRepository),
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

  late final TextEditingController price1Controller;

  FocusNode priceFocus = FocusNode();
  FocusNode priceFocus2 = FocusNode();
  FocusNode priceFocus3 = FocusNode();

  bool hasLowerPrices = false;
  bool stockWasModified = false;
  bool productWasModified = false;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.initialProduct;
    currentSalePrice = currentProduct.saleProfile.salePrice;
    currentSalePrice2 = currentProduct.saleProfile.salePrice2;
    currentSalePrice3 = currentProduct.saleProfile.salePrice3;
    currentDiscounts = [...currentProduct.saleProfile.discounts];
    price1Controller = TextEditingController(
      text: NumberFormatter.convertFromCentsToDouble(
        widget.initialProduct.saleProfile.salePrice,
      ).toString(),
    );
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
      discounts: currentDiscounts,
    );

    final branchId = getIt<AuthCubit>().currentBranchId;
    context.read<WriteProductSaleProfileCubit>().updateProfile(
      branchId,
      currentProduct.id,
      updatedDto,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAuthState = getIt<AuthCubit>().state;

    if (currentAuthState is! Authenticated) {
      return const SizedBox.shrink();
    }

    final isAdmin = currentAuthState.session.isAdmin;

    hasLowerPrices =
        [
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

        final res = await DialogManager.confirmActionDialog(
          context,
          "Deseas salir sin guardar los cambios del precio?",
        );

        if (res != true) return;

        if (!context.mounted) return;

        // If stock or product details were modified, we return the modified product even though price weren't saved
        if (stockWasModified || productWasModified) {
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
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: "Editar Producto",
                    onPressed: () async {
                      final updatedProduct = await showCreateProductDialog(
                        context,
                        product: currentProduct,
                      );

                      if (updatedProduct == null) return;
                      if (!context.mounted) return;

                      if (updatedProduct.isDeleted) {
                        Navigator.pop(context, currentProduct.copyWith(isDeleted: true));
                        return;
                      }

                      setState(() {
                        currentProduct = currentProduct.updateWithProduct(updatedProduct);
                        productWasModified = true;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
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
                        Center(
                          child: ImageViewerWidget(
                            imageUrls: currentProduct.image.isNotEmpty ? [currentProduct.image] : [],
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                  title: "Costo",
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
                                  bigTitleColor: currentProduct.account.currentStock > 0
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
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
                                  backgroundColor: Colors.red.shade100,
                                  foregroundColor: Colors.red.shade900,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text("Restar al inventario"),
                                onPressed: isAdmin
                                    ? () async {
                                        final authState = getIt<AuthCubit>().state;
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
                                      }
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 16),

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
                                  final authState = getIt<AuthCubit>().state;
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
                                    expirationDate: res['expirationDate'],
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

                        Builder(
                          builder: (context) {
                            final appSettings = getIt<AppSettingsCubit>();
                            if (!appSettings.useDefaultProfitMargin) {
                              return const SizedBox.shrink();
                            }
                            final profitMargin = appSettings.defaultProfitMargin;
                            final costInCents = currentProduct.account.averageCost > 0
                                ? currentProduct.account.averageCost
                                : currentProduct.account.lastCost;
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

                        TitleTextField(
                          key: const Key("price1"),
                          title: "Precio de Venta (C\$ )",
                          focusNode: priceFocus,
                          keyboardType: TextInputType.number,
                          controller: price1Controller,
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
