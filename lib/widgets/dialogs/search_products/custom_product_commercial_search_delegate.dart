import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/commercial_product_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<CommercialProductResult?> showCommercialProductSearchDelegate(BuildContext context) async {
  return await Navigator.push<CommercialProductResult?>(
    context,
    MaterialPageRoute(
      builder: (context) => const CustomProductSearchDelegate(),
    ),
  );
}

class CustomProductSearchDelegate extends StatefulWidget {
  const CustomProductSearchDelegate({super.key});

  @override
  State<CustomProductSearchDelegate> createState() => _CustomProductSearchDelegateState();
}

class _CustomProductSearchDelegateState extends State<CustomProductSearchDelegate> {
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
                        products = await context.read<ProductsRepository>().searchProductInBranch(value);
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
              final res = await showCommercialProductModal(context, product: product);
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
      height: 68,
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
