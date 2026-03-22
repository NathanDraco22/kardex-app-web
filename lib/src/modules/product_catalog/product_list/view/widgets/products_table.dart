import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/read_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/dialogs/create_product_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/status_tag_label.dart';

class ProductsTable extends StatelessWidget {
  const ProductsTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadProductCubit>();
    final state = cubit.state as ReadProductSuccess;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  child: SearchFieldDebounced(
                    onSearch: (value) {
                      cubit.searchProductByKeyword(value);
                    },
                  ),
                ),
              ],
            ),
          ),

          if (state is ReadProductSearching) const LinearProgressIndicator(),

          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Text("Nombre del Producto"),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Marca"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Unidad"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Categoria"),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Center(child: Text("Estado")),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          const Divider(),

          Builder(
            builder: (context) {
              if (state.products.isEmpty) {
                return const Center(
                  child: NoItemWidget(
                    icon: Icons.qr_code,
                    text: "No se encontraron productos",
                  ),
                );
              }
              return const _InnerRows();
            },
          ),
        ],
      ),
    );
  }
}

class _InnerRows extends StatelessWidget {
  const _InnerRows();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadProductCubit>();
    final state = cubit.state as ReadProductSuccess;
    final products = state.products;

    return Expanded(
      child: ListView.builder(
        itemCount: products.length,

        itemBuilder: (context, index) {
          final currentProduct = products[index];

          Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

          if (state is HighlightedProduct) {
            if (state.updatedProducts.any((element) => element.id == currentProduct.id)) {
              rowColor = Colors.blue.shade100;
            } else if (state.newProducts.any((element) => element.id == currentProduct.id)) {
              rowColor = Colors.yellow.shade200;
            }
          }

          return _RowWidget(
            product: currentProduct,
            color: rowColor,
          );
        },
      ),
    );
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({
    required this.product,
    required this.color,
  });

  final ProductInDb product;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name),
                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code,
                        size: 16,
                        color: Colors.grey,
                      ),
                      Text(
                        product.displayCode,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(product.brandName),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(product.unitName),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(product.categoryName ?? "--"),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Builder(
                  builder: (context) {
                    if (product.isActive) {
                      return const StatusTagLabel(
                        label: "Activo",
                        isActive: true,
                      );
                    } else {
                      return const StatusTagLabel(
                        label: "Inactivo",
                        isActive: false,
                      );
                    }
                  },
                ),
              ),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.centerRight,

                child: IconButton(
                  onPressed: () async {
                    final res = await showCreateProductDialog(context, product: product);
                    if (res == null) return;
                    if (!context.mounted) return;
                    await context.read<ReadProductCubit>().markProductUpdated(res);
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
