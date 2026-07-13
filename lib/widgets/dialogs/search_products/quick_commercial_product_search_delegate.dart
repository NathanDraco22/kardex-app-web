import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
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

  void _setProductQuantity(ProductInDbInBranch product, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cart.remove(product.id);
        return;
      }

      int finalQuantity = newQuantity;
      if (widget.restrictStock && newQuantity > product.account.availableStock) {
        finalQuantity = product.account.availableStock;
      }

      if (!_cart.containsKey(product.id)) {
        _cart[product.id] = CommercialProductResult(product: product);
      }
      _cart[product.id]!.quantity = finalQuantity;
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
          if (widget.restrictStock && quantity >= product.account.availableStock) {
            canIncrement = false;
          }

          return _ProductInBranchQuickResultRow(
            product: product,
            quantity: quantity,
            color: quantity > 0 ? Colors.amber.shade50 : Colors.white,
            onIncrement: canIncrement ? () => _incrementProduct(product) : null,
            onDecrement: quantity > 0 ? () => _decrementProduct(product) : null,
            onQuantityChanged: (value) {
              final newQuantity = int.tryParse(value) ?? 0;
              _setProductQuantity(product, newQuantity);
            },
          );
        },
      ),
    );
  }
}

class _ProductInBranchQuickResultRow extends StatefulWidget {
  const _ProductInBranchQuickResultRow({
    required this.product,
    required this.quantity,
    this.onIncrement,
    this.onDecrement,
    required this.onQuantityChanged,
    this.color,
  });

  final ProductInDbInBranch product;
  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final ValueChanged<String> onQuantityChanged;
  final Color? color;

  @override
  State<_ProductInBranchQuickResultRow> createState() => _ProductInBranchQuickResultRowState();
}

class _ProductInBranchQuickResultRowState extends State<_ProductInBranchQuickResultRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity == 0 ? "" : widget.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _ProductInBranchQuickResultRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      if (int.tryParse(_controller.text) != widget.quantity) {
        _controller.text = widget.quantity == 0 ? "" : widget.quantity.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int value = widget.product.saleProfile.salePrice;
    String valueToDisplay = NumberFormatter.convertToMoneyLike(value);

    return DecoratedBox(
      decoration: BoxDecoration(color: widget.color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageViewerWidget(
                  imageUrls: widget.product.image.isNotEmpty ? [widget.product.image] : [],
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DisplayProductCode(product: widget.product),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.product.brandName} - ${widget.product.unitName}",
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
                        "Stock: ${widget.product.account.availableStock}",
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.product.account.availableStock > 0 ? Colors.green.shade700 : Colors.red,
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
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onDecrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade100,
                      disabledForegroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.remove, size: 24),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 60,
                  child: Center(
                    child: TextField(
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      controller: _controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [IntegerTextInputFormatter()],
                      keyboardType: TextInputType.number,
                      onChanged: widget.onQuantityChanged,
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onIncrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade100,
                      disabledForegroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.add, size: 24),
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
