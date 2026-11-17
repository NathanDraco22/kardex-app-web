import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/display_product_code.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

Future<ProductInDb?> showProductSearchDelegate(
  BuildContext context, {
  bool onlyInventory = false,
}) async {
  return await Navigator.push<ProductInDb?>(
    context,
    MaterialPageRoute(
      builder: (context) => CustomProductSearchDelegate(onlyInventory: onlyInventory),
    ),
  );
}

class CustomProductSearchDelegate extends StatefulWidget {
  const CustomProductSearchDelegate({super.key, this.onlyInventory = false});

  final bool onlyInventory;

  @override
  State<CustomProductSearchDelegate> createState() => _CustomProductSearchDelegateState();
}

class _CustomProductSearchDelegateState extends State<CustomProductSearchDelegate> {
  bool isSearching = false;

  List<ProductInDb> products = <ProductInDb>[];

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
                        String? activeBranchId;
                        if (getIt.isRegistered<AuthCubit>()) {
                          final authState = getIt<AuthCubit>().state;
                          if (authState is Authenticated) activeBranchId = authState.branch.id;
                        }
                        products = await context.read<ProductsRepository>().searchProductByKeyword(
                              value,
                              branchId: activeBranchId,
                              onlyInventory: widget.onlyInventory ? true : null,
                            );
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
          return _ProductResultRow(
            color: RowColorTool.getRowColor(index),
            product: product,
            onTap: () => Navigator.pop(context, product),
          );
        },
      ),
    );
  }
}

class _ProductResultRow extends StatelessWidget {
  const _ProductResultRow({
    required this.product,
    this.color,
    this.onTap,
  });

  final ProductInDb product;
  final Color? color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
