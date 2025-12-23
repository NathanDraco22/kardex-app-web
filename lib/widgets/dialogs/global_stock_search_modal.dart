import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/widgets/product_stock_dialog.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<void> showGlobalStockSearchModal(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const GlobalStockSearchModal(),
    ),
  );
}

class GlobalStockSearchModal extends StatefulWidget {
  const GlobalStockSearchModal({super.key});

  @override
  State<GlobalStockSearchModal> createState() => _GlobalStockSearchModalState();
}

class _GlobalStockSearchModalState extends State<GlobalStockSearchModal> {
  bool isSearching = false;

  List<ProductInDb> products = <ProductInDb>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Consulta de Existencias"),
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
          return ListTile(
            title: Text(
              product.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Row(
              children: [
                Text(
                  product.brandName,
                ),
              ],
            ),
            trailing: Text(
              product.unitName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => ProductStockDialog.show(context, product),
          );
        },
      ),
    );
  }
}
