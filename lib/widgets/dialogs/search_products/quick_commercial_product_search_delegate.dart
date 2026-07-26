import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

Future<List<CommercialProductResult>?> showQuickCommercialProductSearchDelegate(
  BuildContext context, {
  bool restrictStock = true,
  int defaultPriceLevel = 1,
  String preferredUnitType = 'min',
}) async {
  return await Navigator.push<List<CommercialProductResult>?>(
    context,
    MaterialPageRoute(
      builder: (context) => QuickProductSearchDelegate(
        restrictStock: restrictStock,
        defaultPriceLevel: defaultPriceLevel,
        preferredUnitType: preferredUnitType,
      ),
    ),
  );
}

class QuickProductSearchDelegate extends StatefulWidget {
  const QuickProductSearchDelegate({
    super.key,
    this.restrictStock = true,
    this.defaultPriceLevel = 1,
    this.preferredUnitType = 'min',
  });

  final bool restrictStock;
  final int defaultPriceLevel;
  final String preferredUnitType;

  @override
  State<QuickProductSearchDelegate> createState() => _QuickProductSearchDelegateState();
}

class _QuickProductSearchDelegateState extends State<QuickProductSearchDelegate> {
  bool isSearching = false;

  List<ProductInDbInBranch> products = [];

  final Map<String, CommercialProductResult> _cart = {};

  void _incrementProduct(ProductInDbInBranch product) {
    setState(() {
      if (_cart.containsKey(product.id)) {
        _cart[product.id]!.quantity += 1;
      } else {
        final result = CommercialProductResult(
          product: product,
          defaultPriceLevel: widget.defaultPriceLevel,
          preferredUnitType: widget.preferredUnitType,
        );
        result.quantity = 1;
        _cart[product.id] = result;
      }
    });
  }

  void _decrementProduct(ProductInDbInBranch product) {
    setState(() {
      if (_cart.containsKey(product.id)) {
        if (_cart[product.id]!.quantity > 1) {
          _cart[product.id]!.quantity -= 1;
        } else {
          _cart.remove(product.id);
        }
      }
    });
  }

  int _getQuantity(ProductInDbInBranch product) {
    return _cart[product.id]?.quantity ?? 0;
  }

  int _resolveDisplayFactor(ProductInDbInBranch product) {
    int index;
    if (widget.preferredUnitType == "max" && product.wholesaleUnitIndex > 0) {
      index = product.wholesaleUnitIndex;
    } else {
      index = product.defaultUnitIndex;
    }
    if (product.extraUnits.isEmpty || index > product.extraUnits.length || index == 0) return 1;
    return product.extraUnits[index - 1].conversionFactor;
  }

  @override
  Widget build(BuildContext context) {
    final cartItemsCount = _cart.values.fold<int>(0, (prev, curr) => prev + curr.quantity);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Búsqueda Rápida"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (_cart.isNotEmpty) {
              final result = await DialogManager.confirmActionDialog(
                context,
                "¿Estás seguro de que deseas salir sin guardar los cambios?",
              );
              if (!result) return;
            }
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_cart.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context, _cart.values.toList());
              },
              icon: const Icon(Icons.check),
              label: Text("Listo ($cartItemsCount)"),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Column(
            children: [
              Row(
                children: [
                  Flexible(
                    child: SearchFieldDebounced(
                      autoFocus: true,
                      onSearch: (value) async {
                        if (value.isEmpty) return;
                        isSearching = true;
                        setState(() {});
                        final branchId = getIt<AuthCubit>().currentBranchId;
                        products = await context.read<ProductsRepository>().searchProductInBranch(value, branchId);
                        isSearching = false;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              if (isSearching) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(
          height: 0.0,
          thickness: 1.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final quantity = _getQuantity(product);

          bool canIncrement = true;
          if (widget.restrictStock && (quantity * _resolveDisplayFactor(product)) >= product.account.availableStock) {
            canIncrement = false;
          }

          return _ProductInBranchQuickResultRow(
            product: product,
            quantity: quantity,
            preferredUnitType: widget.preferredUnitType,
            color: quantity > 0 ? Colors.amber.shade50 : Colors.white,
            onIncrement: canIncrement ? () => _incrementProduct(product) : null,
            onDecrement: quantity > 0 ? () => _decrementProduct(product) : null,
          );
        },
      ),
    );
  }
}

class _ProductInBranchQuickResultRow extends StatelessWidget {
  const _ProductInBranchQuickResultRow({
    required this.product,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    this.preferredUnitType = 'min',
    this.color,
  });

  final ProductInDbInBranch product;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final String preferredUnitType;
  final Color? color;

  int get _resolvedUnitIndex {
    if (preferredUnitType == "max" && product.wholesaleUnitIndex > 0) {
      return product.wholesaleUnitIndex;
    }
    return product.defaultUnitIndex;
  }

  String get _displayUnitName {
    if (_resolvedUnitIndex == 0 || product.extraUnits.isEmpty) return product.unitName;
    final idx = _resolvedUnitIndex - 1;
    if (idx >= 0 && idx < product.extraUnits.length) return product.extraUnits[idx].name;
    return product.unitName;
  }

  int get _displayConversionFactor {
    if (_resolvedUnitIndex == 0 || product.extraUnits.isEmpty) return 1;
    final idx = _resolvedUnitIndex - 1;
    if (idx >= 0 && idx < product.extraUnits.length) return product.extraUnits[idx].conversionFactor;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    int value = product.saleProfile.salePrice * _displayConversionFactor;
    String valueToDisplay = NumberFormatter.convertToMoneyLike(value);

    return DecoratedBox(
      decoration: BoxDecoration(color: color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageViewerWidget(
                  imageUrls: product.image.isNotEmpty ? [product.image] : [],
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DisplayProductCode(product: product),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.brandName,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              " - ",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            UnitDisplayer(
                              unitName: _displayUnitName,
                              conversionFactor: _displayConversionFactor,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        valueToDisplay,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stock: ${NumberFormatter.formatDisplayStock(product.account.availableStock, _displayConversionFactor)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: product.account.availableStock > 0 ? Colors.green.shade700 : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Controles del Carrito + y - más grandes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onDecrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade100,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.remove, size: 18),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: onIncrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
