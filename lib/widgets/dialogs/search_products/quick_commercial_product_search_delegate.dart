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
}) async {
  return await Navigator.push<List<CommercialProductResult>?>(
    context,
    MaterialPageRoute(
      builder: (context) => QuickProductSearchDelegate(
        restrictStock: restrictStock,
      ),
    ),
  );
}

class QuickProductSearchDelegate extends StatefulWidget {
  const QuickProductSearchDelegate({
    super.key,
    this.restrictStock = true,
  });

  final bool restrictStock;

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
        final result = CommercialProductResult(product: product);
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
          if (widget.restrictStock && (quantity * product.defaultUnitFactor) >= product.account.availableStock) {
            canIncrement = false;
          }

          return _ProductInBranchQuickResultRow(
            product: product,
            quantity: quantity,
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
    this.color,
  });

  final ProductInDbInBranch product;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    int value = product.saleProfile.salePrice * product.defaultUnitFactor;
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
                      Text(
                        "${product.brandName} - ${product.defaultUnitName}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                        "Stock: ${NumberFormatter.formatDisplayStock(product.account.availableStock, product.defaultUnitFactor)}",
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
