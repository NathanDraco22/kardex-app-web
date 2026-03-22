import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<ProductInDb?> showProductSearchDelegate(BuildContext context) async {
  return await Navigator.push<ProductInDb?>(
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
                        products = await context.read<ProductsRepository>().searchProductByKeyword(value);
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
            color: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
