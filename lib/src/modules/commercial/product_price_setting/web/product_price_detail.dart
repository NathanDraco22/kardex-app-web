import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/dialogs/discount_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/product_price_setting/widgets/discount_tile.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../cubit/read_product_sale_profile_cubit.dart';
import '../cubit/write_product_sale_profile_cubit.dart';

Future<void> showProductPriceDetail(
  BuildContext context,
  ProductSaleProfileInDbWithProduct profile,
) async {
  final writeCubit = context.read<WriteProductSaleProfileCubit>();
  final readCubit = context.read<ReadProductSaleProfileCubit>();

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: writeCubit),
          BlocProvider.value(value: readCubit),
        ],
        child: ProductPriceDetail(profile: profile),
      ),
    ),
  );
}

class ProductPriceDetail extends StatelessWidget {
  const ProductPriceDetail({super.key, required this.profile});

  final ProductSaleProfileInDbWithProduct profile;

  @override
  Widget build(BuildContext context) {
    return _RootScaffold(profile);
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold(this.profile);

  final ProductSaleProfileInDbWithProduct profile;

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  late ProductSaleProfileInDbWithProduct currentProfile;

  FocusNode priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    currentProfile = widget.profile.copyWith(
      discounts: [...widget.profile.discounts],
    );
    Future(
      () {
        priceFocus.requestFocus();
      },
    );
  }

  void _saveProduct() {
    final updatedDto = UpdateProductSaleProfile(
      salePrice: currentProfile.salePrice,
      discounts: currentProfile.discounts,
    );
    context.read<WriteProductSaleProfileCubit>().updateProfile(
      currentProfile.productId,
      updatedDto,
    );
  }

  @override
  Widget build(BuildContext context) {
    log(currentProfile.hashCode.toString());
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
                context.read<ReadProductSaleProfileCubit>().markProductUpdated(state.profile);
                LoadingDialogManager.closeLoadingDialog(context);
                await DialogManager.showInfoDialog(context, "Guardado exitosamente");
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Configuracion de Precios"),
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
                          currentProfile.product.name,
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
                              currentProfile.product.brandName,
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
                              currentProfile.product.unitName,
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
                                  currentProfile.account.averageCost,
                                ),
                              ),
                              const VerticalDivider(),

                              TitleLabel(
                                title: "Ultima Compra",
                                bigTitle: NumberFormatter.convertToMoneyLike(
                                  currentProfile.account.lastCost,
                                ),
                              ),
                              const VerticalDivider(),

                              TitleLabel(
                                title: "Costo Maximo",
                                bigTitle: NumberFormatter.convertToMoneyLike(
                                  currentProfile.account.maximumCost,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        TitleTextField(
                          title: "Precio de Venta (C\$ )",
                          focusNode: priceFocus,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              currentProfile.salePrice = 0;
                              setState(() {});
                              return;
                            }
                            final formattedValue = value.replaceAll(",", "");
                            final cents = (double.parse(formattedValue) * 100).round();
                            currentProfile.salePrice = cents;
                            setState(() {});
                          },

                          initialValue: NumberFormatter.convertFromCentsToDouble(
                            widget.profile.salePrice,
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

                                currentProfile.discounts.add(res);
                                setState(() {});
                              },
                            ),
                          ],
                        ),

                        _DiscountListViewContainer(
                          profile: currentProfile,
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
  const _DiscountListViewContainer({required this.profile});

  final ProductSaleProfileInDbWithProduct profile;

  @override
  State<_DiscountListViewContainer> createState() => _DiscountListViewContainerState();
}

class _DiscountListViewContainerState extends State<_DiscountListViewContainer> {
  @override
  Widget build(BuildContext context) {
    final discounts = widget.profile.discounts;
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
          final currentPrice = widget.profile.salePrice;
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
