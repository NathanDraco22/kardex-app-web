import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/read_product_in_branch/read_product_in_branch_cubit.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/dialogs/product_inventory_editor_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';

part 'sections/content_section.dart';

class ProductInventoryCatalogWeb extends StatelessWidget {
  const ProductInventoryCatalogWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadProductInBranchCubit>();
    final state = readCubit.state;

    if (state is ReadProductInBranchLoading || state is ReadProductInBranchInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ReadProductInBranchFailure) {
      return Center(child: Text(state.message));
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      flex: 2,
                      child: TextButton.icon(
                        onPressed: () async {
                          ProductInDbInBranch? selectedProduct;
                          if (!context.isMobile()) {
                            selectedProduct = await showSearchProductInBranchDialog(context);
                          } else {
                            selectedProduct = await showSearchProductInBranchDelegate(context, false);
                          }

                          if (selectedProduct != null && context.mounted) {
                            final updatedProduct = await showProductInventoryEditor(context, selectedProduct);
                            if (updatedProduct != null && context.mounted) {
                              context.read<ReadProductInBranchCubit>().markProductAsEdited(updatedProduct);
                            }
                          }
                        },
                        icon: const Icon(Icons.search),
                        label: const Text("Buscar producto"),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              const Expanded(
                child: _ContentSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
