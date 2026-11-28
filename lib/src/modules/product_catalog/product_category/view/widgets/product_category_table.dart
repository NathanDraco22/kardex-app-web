import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/product_category_cubit/read_product_category_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/dialogs/create_product_category_dialog.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

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

                Color rowColor = RowColorTool.getRowColor(index);

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
                    onPressed: () {
                      showCreateProductCategoryDialog(
                        context,
                        category: currentProductCategory,
                      );
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
