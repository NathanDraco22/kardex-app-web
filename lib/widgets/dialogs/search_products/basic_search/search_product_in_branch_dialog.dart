import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/product_repository.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<ProductInDbInBranch?> showSearchProductInBranchDialog(
  BuildContext context, {
  ProductInDbInBranch? product,
  bool useAverageCost = false,
}) async {
  final res = await showDialog<ProductInDbInBranch?>(
    context: context,
    builder: (context) => SearchProductInBranchDialog(
      product: product,
      useAverageCost: useAverageCost,
    ),
  );
  return res;
}

class SearchProductInBranchDialog extends StatefulWidget {
  const SearchProductInBranchDialog({
    super.key,
    this.product,
    this.useAverageCost = false,
  });

  final ProductInDbInBranch? product;
  final bool useAverageCost;

  @override
  State<SearchProductInBranchDialog> createState() => _SearchProductInBranchDialogState();
}

class _SearchProductInBranchDialogState extends State<SearchProductInBranchDialog> {
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
                      flex: 2,
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent) {
                            if (event.logicalKey == LogicalKeyboardKey.enter) {
                              if (products.isNotEmpty) {
                                Navigator.pop(context, products[cursorPosition]);
                                return KeyEventResult.handled;
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
                            products = await _productsRepository.searchProductInBranch(value);
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
                  height: 320,
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
                        cursorPosition: cursorPosition,
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
    this.focus,
    this.cursorPosition = 0,
  });

  final List<ProductInDbInBranch> products;
  final FocusNode? focus;
  final int cursorPosition;

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

        return ProductInBranchResultRow(
          product: product,
          onTap: () async {
            Navigator.pop(context, product);
          },
          color: color,
        );
      },
    );
  }
}

class ProductInBranchResultRow extends StatelessWidget {
  const ProductInBranchResultRow({
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
    final parentWidget = context.findAncestorWidgetOfExactType<SearchProductInBranchDialog>()!;
    int value = product.saleProfile.salePrice;

    if (parentWidget.useAverageCost == true) {
      value = product.account.averageCost;
    }

    String valueToDisplay = NumberFormatter.convertToMoneyLike(value);

    if (parentWidget.useAverageCost == true) {
      valueToDisplay = NumberFormatter.convertFromCentsToDouble(product.account.averageCost).toString();
    }

    return SizedBox(
      height: 60,
      child: InkWell(
        hoverColor: Colors.yellow.shade100,
        focusColor: Colors.yellow.shade100,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color),
          child: Row(
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
                  child: Text(
                    valueToDisplay,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
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
