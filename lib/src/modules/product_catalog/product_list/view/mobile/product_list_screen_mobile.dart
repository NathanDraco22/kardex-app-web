part of '../product_list_screen.dart';

class ProductListScreenMobile extends StatelessWidget {
  const ProductListScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  Future<void> _onCreateProduct(BuildContext context) async {
    final res = await showCreateProductDialog(context);
    if (res == null) return;
    if (!context.mounted) return;
    await context.read<ReadProductCubit>().putProductFirst(res);
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadProductCubit>();
    final state = readCubit.state;

    if (state is ReadProductInitial || state is ReadProductLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lista Global de Productos")),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ProductReadError) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lista Global de Productos")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(state.message),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Lista Global de Productos")),
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () => _onCreateProduct(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text("Nuevo Producto"),
        ),
      ),
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(4.0),
      child: MobileProductsTable(),
    );
  }
}

class MobileProductsTable extends StatelessWidget {
  const MobileProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadProductCubit>();
    final state = readCubit.state as ReadProductSuccess;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: SearchFieldDebounced(
              onSearch: (value) => readCubit.searchProductByKeyword(value),
            ),
          ),
          _MobileTypeFilterBar(
            selectedType: readCubit.selectedTypeFilter,
            onSelected: readCubit.setTypeFilter,
          ),

          if (state is ReadProductSearching) const LinearProgressIndicator(),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          Expanded(
            child: state.products.isEmpty
                ? const Center(
                    child: NoItemWidget(
                      icon: Icons.qr_code,
                      text: "No hay productos",
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.products.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE2E8F0),
                    ),
                    itemBuilder: (context, index) {
                      final currentProduct = state.products[index];

                      Color rowColor = RowColorTool.getRowColor(index);

                      if (state is HighlightedProduct) {
                        if (state.updatedProducts.any((element) => element.id == currentProduct.id)) {
                          rowColor = Colors.blue.shade100;
                        } else if (state.newProducts.any((element) => element.id == currentProduct.id)) {
                          rowColor = Colors.yellow.shade200;
                        }
                      }

                      return _ProductMobileRow(
                        product: currentProduct,
                        color: rowColor,
                        onEdit: () async {
                          final res = await showCreateProductDialog(context, product: currentProduct);
                          if (res == null) return;
                          if (!context.mounted) return;
                          await readCubit.markProductUpdated(res);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MobileTypeFilterBar extends StatelessWidget {
  const _MobileTypeFilterBar({
    required this.selectedType,
    required this.onSelected,
  });

  final ProductType? selectedType;
  final ValueChanged<ProductType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(ProductType?, String)>[
      (null, "Todos"),
      (ProductType.item, "Artículos"),
      (ProductType.nonInventory, "No inv."),
      (ProductType.service, "Servicios"),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            ChoiceChip(
              label: Text(options[i].$2),
              selected: selectedType == options[i].$1,
              visualDensity: VisualDensity.compact,
              onSelected: (_) => onSelected(options[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductMobileRow extends StatelessWidget {
  const _ProductMobileRow({
    required this.product,
    required this.color,
    required this.onEdit,
  });

  final ProductInDb product;
  final Color color;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final brand = product.brandName.trim();
    final category = product.categoryName?.trim() ?? "";

    return Material(
      color: color,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageViewerWidget(
                imageUrls: product.image.isNotEmpty ? [product.image] : const [],
                width: 52,
                height: 52,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusTagLabel(
                          label: product.isActive ? "Activo" : "Inactivo",
                          isActive: product.isActive,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.qr_code, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            product.altCode.trim().isNotEmpty
                                ? "${product.displayCode} • Alt: ${product.altCode.trim()}"
                                : product.displayCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaChip(label: product.defaultUnitName),
                        if (brand.isNotEmpty) _MetaChip(label: brand),
                        if (category.isNotEmpty) _MetaChip(label: category),
                        if (!product.tracksInventory)
                          ProductTypeBadge(
                            productType: product.productType,
                            compact: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Editar producto",
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}
