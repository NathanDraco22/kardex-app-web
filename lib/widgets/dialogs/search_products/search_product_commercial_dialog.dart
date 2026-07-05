import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial_product_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

import '../models/commercial_product_result.dart';

Future<CommercialProductResult?> showSearchProductCommercialDialog(
  BuildContext context, {
  ProductInDb? product,
  bool isDirectSale = false,
  int defaultPriceLevel = 1,
}) async {
  final res = await showDialog<CommercialProductResult?>(
    context: context,
    builder: (context) => SearchProductCommercialDialog(
      product: product,
      isDirectSale: isDirectSale,
      defaultPriceLevel: defaultPriceLevel,
    ),
  );
  return res;
}

class SearchProductCommercialDialog extends StatefulWidget {
  const SearchProductCommercialDialog({
    super.key,
    this.product,
    required this.isDirectSale,
    this.defaultPriceLevel = 1,
  });

  final ProductInDb? product;
  final bool isDirectSale;
  final int defaultPriceLevel;

  @override
  State<SearchProductCommercialDialog> createState() => _SearchProductCommercialDialogState();
}

class _SearchProductCommercialDialogState extends State<SearchProductCommercialDialog> {
  late ProductsRepository _productsRepository;

  String title = "Buscar Producto";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productsRepository = context.read<ProductsRepository>();

    if (widget.product != null) {
      title = "Cambiar: ${widget.product!.name} ${widget.product!.brandName} ${widget.product!.unitName}";
    }
  }

  final tableFocus = FocusNode();

  List<ProductInDbInBranch> products = [];

  int cursorPosition = 0;

  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 700,
        child: Dialog(
          constraints: const BoxConstraints(maxWidth: 700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.enter) {
                              if (products.isNotEmpty) {
                                if (widget.isDirectSale) {
                                  final result = CommercialProductResult(
                                    product: products[cursorPosition],
                                    defaultPriceLevel: widget.defaultPriceLevel,
                                  );
                                  Navigator.pop(context, result);
                                  return KeyEventResult.handled;
                                }
                                showCommercialProductDialog(
                                  context,
                                  product: products[cursorPosition],
                                  defaultPriceLevel: widget.defaultPriceLevel,
                                ).then((value) {
                                  if (value == null) return;

                                  if (!context.mounted) return;
                                  Navigator.pop(context, value);
                                });
                              }
                              return KeyEventResult.handled;
                            }
                            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                              cursorPosition = (cursorPosition - 1 + products.length) % products.length;
                              setState(() {});
                              return KeyEventResult.handled;
                            }
                            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                              cursorPosition = (cursorPosition + 1) % products.length;
                              setState(() {});
                              return KeyEventResult.handled;
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: SearchFieldDebounced(
                          autoFocus: true,
                          onSearch: (value) async {
                            if (value.isEmpty) {
                              products = [];
                              setState(() {});
                              return;
                            }
                            isSearching = true;
                            setState(() {});
                            final branchId = getIt<AuthCubit>().currentBranchId;
                            products = await _productsRepository.searchProductInBranch(value, branchId);
                            if (!mounted) return;
                            isSearching = false;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CloseButton(
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                isSearching ? const LinearProgressIndicator() : const SizedBox(),
                SizedBox(
                  height: 300,
                  child: Builder(
                    builder: (context) {
                      if (products.isEmpty) {
                        return const Center(
                          child: NoItemWidget(
                            icon: Icons.search,
                            text: "No se encontraron productos",
                          ),
                        );
                      }
                      return ResultTable(
                        products: products,
                        isDirectSale: widget.isDirectSale,
                        cursorPosition: cursorPosition,
                        defaultPriceLevel: widget.defaultPriceLevel,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultTable extends StatefulWidget {
  const ResultTable({
    super.key,
    required this.products,
    required this.isDirectSale,
    this.focus,
    this.cursorPosition = 0,
    this.defaultPriceLevel = 1,
  });

  final List<ProductInDbInBranch> products;
  final FocusNode? focus;
  final int cursorPosition;
  final bool isDirectSale;
  final int defaultPriceLevel;

  @override
  State<ResultTable> createState() => _ResultTableState();
}

class _ResultTableState extends State<ResultTable> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return const Divider(
          height: 8.0,
          thickness: 2,
        );
      },
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        Color? color;

        if (index == widget.cursorPosition) {
          color = Colors.yellow.shade100;
        }

        return ProductResultRow(
          product: product,
          onTap: () async {
            if (widget.isDirectSale) {
              final result = CommercialProductResult(
                product: product,
                defaultPriceLevel: widget.defaultPriceLevel,
              );
              Navigator.pop(context, result);
              return;
            }

            final res = await showCommercialProductDialog(
              context,
              product: product,
              defaultPriceLevel: widget.defaultPriceLevel,
            );

            if (res == null) return;

            if (!context.mounted) return;
            Navigator.pop(context, res);
          },
          color: color,
        );
      },
    );
  }
}

class ProductResultRow extends StatelessWidget {
  const ProductResultRow({
    super.key,
    required this.product,
    this.color,
    this.onTap,
  });

  final ProductInDbInBranch product;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: InkWell(
        hoverColor: Colors.yellow.shade100,
        focusColor: Colors.yellow.shade100,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color),
          child: Row(
            crossAxisAlignment: .center,
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: .center,
                  children: [
                    DisplayProductCode(product: product),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(product.brandName),
                        ),

                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(product.unitName),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  product.account.availableStock.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      final price = NumberFormatter.convertToMoneyLike(
                        product.saleProfile.salePrice,
                      );
                      return Text(
                        price,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
