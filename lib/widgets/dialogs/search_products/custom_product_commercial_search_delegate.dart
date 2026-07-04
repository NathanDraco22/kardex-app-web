import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial_product_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/product_in_branch_info_dialog.dart';

Future<CommercialProductResult?> showCommercialProductSearchDelegate(
  BuildContext context, {
  int defaultPriceLevel = 1,
}) async {
  return await Navigator.push<CommercialProductResult?>(
    context,
    MaterialPageRoute(
      builder: (context) => CustomProductSearchDelegate<CommercialProductResult>(
        onSelect: (ctx, product) => showCommercialProductModal(
          ctx,
          product: product,
          defaultPriceLevel: defaultPriceLevel,
        ),
      ),
    ),
  );
}

Future<void> showProductInfoSearchDelegate(BuildContext context) async {
  return await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => CustomProductSearchDelegate<void>(
        onSelect: (ctx, product) async {
          await showProductInBranchInfoDialog(ctx, product: product);
        },
      ),
    ),
  );
}

class CustomProductSearchDelegate<T> extends StatefulWidget {
  const CustomProductSearchDelegate({
    super.key,
    required this.onSelect,
  });

  final Future<T?> Function(BuildContext, ProductInDbInBranch) onSelect;

  @override
  State<CustomProductSearchDelegate<T>> createState() => _CustomProductSearchDelegateState<T>();
}

class _CustomProductSearchDelegateState<T> extends State<CustomProductSearchDelegate<T>> {
  bool isSearching = false;

  List<ProductInDbInBranch> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Buscar Producto"),
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

          return _ProductInBranchResultRow(
            product: product,
            color: Colors.white,
            onTap: () async {
              final res = await widget.onSelect(context, product);
              if (res == null) return;
              if (!context.mounted) return;
              Navigator.pop(context, res);
            },
          );
        },
      ),
    );
  }
}

class _ProductInBranchResultRow extends StatelessWidget {
  const _ProductInBranchResultRow({
    required this.product,
    this.color,
    this.onTap,
  });

  final ProductInDbInBranch product;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    int value = product.saleProfile.salePrice;

    String valueToDisplay = NumberFormatter.convertToMoneyLike(value);

    return SizedBox(
      height: 88,
      child: InkWell(
        hoverColor: Colors.yellow.shade100,
        focusColor: Colors.yellow.shade100,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
      ),
    );
  }
}
