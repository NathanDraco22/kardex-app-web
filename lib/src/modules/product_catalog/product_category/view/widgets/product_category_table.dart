import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/cubit/read_product_category_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/dialogs/create_product_category_dialog.dart';

class ProductCategoryTable extends StatelessWidget {
  const ProductCategoryTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadProductCategoryCubit>();
    final state = cubit.state as ReadProductCategorySuccess;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: state.productCategories.length,

              itemBuilder: (context, index) {
                final currentProductCategory = state.productCategories[index];

                Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                if (state is HighlightedProductCategory) {
                  if (state.updatedProductCategories.any((element) => element.id == currentProductCategory.id)) {
                    rowColor = Colors.indigo.shade200;
                  } else if (state.newProductCategories.any((element) => element.id == currentProductCategory.id)) {
                    rowColor = Colors.yellow.shade200;
                  }
                }

                return ListTile(
                  minTileHeight: 64,
                  tileColor: rowColor,
                  title: Text(currentProductCategory.name),
                  trailing: IconButton(
                    onPressed: () async {
                      final res = await showCreateProductCategoryDialog(
                        context,
                        category: currentProductCategory,
                      );
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadProductCategoryCubit>().markProductCategoryUpdated(res);
                      if (!context.mounted) return;
                      context.read<ReadProductCategoryCubit>().refreshProductCategory();
                    },
                    icon: const Icon(
                      Icons.edit,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
