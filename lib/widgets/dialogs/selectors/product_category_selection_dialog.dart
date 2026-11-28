import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/product_category_cubit/read_product_category_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/dialogs/create_product_category_dialog.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class ProductCategorySelection {
  const ProductCategorySelection(this.category);

  final ProductCategoryInDb? category;
}

Future<ProductCategorySelection?> showProductCategorySelectionDialog(
  BuildContext context, {
  String? selectedCategoryName,
  bool showNoCategoryOption = true,
}) async {
  return await showDialog<ProductCategorySelection?>(
    context: context,
    builder: (context) => ProductCategorySelectionDialog(
      selectedCategoryName: selectedCategoryName,
      showNoCategoryOption: showNoCategoryOption,
    ),
  );
}

class ProductCategorySelectionDialog extends StatefulWidget {
  const ProductCategorySelectionDialog({
    super.key,
    this.selectedCategoryName,
    this.showNoCategoryOption = true,
  });

  final String? selectedCategoryName;
  final bool showNoCategoryOption;

  @override
  State<ProductCategorySelectionDialog> createState() => _ProductCategorySelectionDialogState();
}

class _ProductCategorySelectionDialogState extends State<ProductCategorySelectionDialog> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ReadProductCategoryCubit>().ensureLoaded();
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  List<ProductCategoryInDb> _filterCategories(List<ProductCategoryInDb> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _createCategory() async {
    final created = await showCreateProductCategoryDialog(context);
    if (!mounted || created == null) return;
    Navigator.pop(context, ProductCategorySelection(created));
  }

  @override
  Widget build(BuildContext context) {
    final dialogHeight = (MediaQuery.sizeOf(context).height * 0.68).clamp(320.0, 620.0).toDouble();
    final selectedCategoryName = widget.selectedCategoryName?.trim();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Text("Buscar Categoría de Producto")),
          IconButton(
            tooltip: "Cerrar",
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        height: dialogHeight,
        child: Column(
          children: [
            SearchFieldDebounced(
              autoFocus: true,
              hintText: "Nombre",
              duration: const Duration(milliseconds: 250),
              onSearch: _onSearch,
            ),
            if (widget.showNoCategoryOption) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  avatar: const Icon(Icons.label_off_outlined, size: 18),
                  label: const Text("Sin categoría"),
                  onPressed: () => Navigator.pop(context, const ProductCategorySelection(null)),
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _createCategory,
                icon: const Icon(Icons.add),
                label: const Text("Crear Categoría de Producto"),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ReadProductCategoryCubit, ReadProductCategoryState>(
                builder: (context, state) {
                  if (state is ReadProductCategoryLoading || state is ReadProductCategoryInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductCategoryReadError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Error: ${state.message}",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => context.read<ReadProductCategoryCubit>().loadAllProductCategories(),
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reintentar"),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is! ReadProductCategorySuccess) {
                    return const SizedBox.shrink();
                  }

                  if (state.productCategories.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Aún no hay categorías de producto registradas.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final categories = _filterCategories(state.productCategories);
                  if (categories.isEmpty) {
                    return const Center(child: Text("No se encontraron categorías"));
                  }

                  return ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          selectedCategoryName != null &&
                          selectedCategoryName.isNotEmpty &&
                          category.name.trim() == selectedCategoryName;

                      return _ProductCategoryResultTile(
                        category: category,
                        isSelected: isSelected,
                        onTap: () => Navigator.pop(context, ProductCategorySelection(category)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCategoryResultTile extends StatelessWidget {
  const _ProductCategoryResultTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ProductCategoryInDb category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = category.name.trim();
    final initial = name.isEmpty ? null : name.substring(0, 1).toUpperCase();

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        child: initial == null ? const Icon(Icons.category_outlined) : Text(initial),
      ),
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}
