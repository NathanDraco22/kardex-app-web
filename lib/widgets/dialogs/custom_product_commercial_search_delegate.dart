import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/widgets/dialogs/commercial_product_modal.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_app_front/widgets/search_debounce.dart';

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
          return ListTile(
            title: Text(product.name),
            subtitle: Row(
              children: [
                Text(product.brandName),
              ],
            ),
            trailing: Text(product.unitName),
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
