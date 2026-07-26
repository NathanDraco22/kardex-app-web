import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/search_product_dialog_panel.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial/commercial_product_dialog.dart';

import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

import '../../models/commercial_product_result.dart';

Future<CommercialProductResult?> showSearchProductCommercialDialog(
  BuildContext context, {
  ProductInDb? product,
  bool isDirectSale = false,
  int defaultPriceLevel = 1,
  String preferredUnitType = 'min',
  bool restrictStock = true,
}) async {
  final res = await showDialog<CommercialProductResult?>(
    context: context,
    builder: (context) => SearchProductCommercialDialog(
      product: product,
      isDirectSale: isDirectSale,
      defaultPriceLevel: defaultPriceLevel,
      preferredUnitType: preferredUnitType,
      restrictStock: restrictStock,
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
    this.preferredUnitType = 'min',
    this.restrictStock = true,
  });

  final ProductInDb? product;
  final bool isDirectSale;
  final int defaultPriceLevel;
  final String preferredUnitType;
  final bool restrictStock;

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
      title = "Cambiar: ${widget.product!.name} ${widget.product!.brandName} ${widget.product!.defaultUnitName}";
    }
  }

  List<GlobalKey> _itemKeys = [];

  List<ProductInDbInBranch> products = [];

  int cursorPosition = 0;

  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return SearchProductDialogPanel(
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
                    if (event is! KeyDownEvent) {
                      return KeyEventResult.ignored;
                    }

                    if (products.isEmpty) {
                      return KeyEventResult.ignored;
                    }

                    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      cursorPosition = (cursorPosition - 1 + products.length) % products.length;
                      setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCursor());
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      cursorPosition = (cursorPosition + 1) % products.length;
                      setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCursor());
                      return KeyEventResult.handled;
                    }

                    if (event.logicalKey != LogicalKeyboardKey.enter) {
                      return KeyEventResult.ignored;
                    }

                    if (widget.isDirectSale) {
                      final result = CommercialProductResult(
                        product: products[cursorPosition],
                        defaultPriceLevel: widget.defaultPriceLevel,
                        preferredUnitType: widget.preferredUnitType,
                      );
                      Navigator.pop(context, result);
                      return KeyEventResult.handled;
                    }

                    showCommercialProductDialog(
                      context,
                      product: products[cursorPosition],
                      defaultPriceLevel: widget.defaultPriceLevel,
                      preferredUnitType: widget.preferredUnitType,
                      restrictStock: widget.restrictStock,
                    ).then((value) {
                      if (value == null) return;

                      if (!context.mounted) return;
                      Navigator.pop(context, value);
                    });

                    return KeyEventResult.handled;
                  },
                  child: SearchFieldDebounced(
                    autoFocus: true,
                    onSearch: (value) async {
                      if (value.isEmpty) {
                        products = [];
                        _itemKeys = [];
                        cursorPosition = 0;
                        setState(() {});
                        return;
                      }
                      isSearching = true;
                      setState(() {});
                      final branchId = getIt<AuthCubit>().currentBranchId;
                      products = await _productsRepository.searchProductInBranch(value, branchId);
                      if (!mounted) return;
                      _itemKeys = products.map((_) => GlobalKey()).toList();
                      cursorPosition = 0;
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
                  itemKeys: _itemKeys,
                  cursorPosition: cursorPosition,
                  defaultPriceLevel: widget.defaultPriceLevel,
                  preferredUnitType: widget.preferredUnitType,
                  restrictStock: widget.restrictStock,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToCursor() {
    if (cursorPosition >= _itemKeys.length) return;
    final ctx = _itemKeys[cursorPosition].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 200),
    );
  }
}

class ResultTable extends StatefulWidget {
  const ResultTable({
    super.key,
    required this.products,
    required this.isDirectSale,
    this.itemKeys,
    this.cursorPosition = 0,
    this.defaultPriceLevel = 1,
    this.preferredUnitType = 'min',
    this.restrictStock = true,
  });

  final List<ProductInDbInBranch> products;
  final List<GlobalKey>? itemKeys;
  final int cursorPosition;
  final bool isDirectSale;
  final int defaultPriceLevel;
  final String preferredUnitType;
  final bool restrictStock;

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
          key: widget.itemKeys?[index],
          product: product,
          onTap: () async {
            if (widget.isDirectSale) {
              final result = CommercialProductResult(
                product: product,
                defaultPriceLevel: widget.defaultPriceLevel,
                preferredUnitType: widget.preferredUnitType,
              );
              Navigator.pop(context, result);
              return;
            }

            final res = await showCommercialProductDialog(
              context,
              product: product,
              defaultPriceLevel: widget.defaultPriceLevel,
              preferredUnitType: widget.preferredUnitType,
              restrictStock: widget.restrictStock,
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
              const SizedBox(width: 8),
              ImageViewerWidget(
                imageUrls: product.image.isNotEmpty ? [product.image] : [],
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 8),
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
                          child: Text(product.defaultUnitName),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  NumberFormatter.formatDisplayStock(
                    product.account.availableStock,
                    product.defaultUnitFactor,
                  ),
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
                        product.saleProfile.salePrice * product.defaultUnitFactor,
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
