part of '../sale_terminal_screen_tablet.dart';

class _TabletProductsSection extends StatefulWidget {
  const _TabletProductsSection();

  @override
  State<_TabletProductsSection> createState() => _TabletProductsSectionState();
}

class _TabletProductsSectionState extends State<_TabletProductsSection> {
  String? _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ReadTerminalProductCubit>().getNextPagedProducts();
    }
  }

  void _quickAdd(BuildContext context, ProductInDbInBranch product) {
    final viewController = SaleTerminalTabletMediator.of(context).viewController;
    final result = CommercialProductResult(
      product: product,
      defaultPriceLevel: viewController.selectedPriceLevel,
      preferredUnitType: viewController.isWholesale ? 'max' : 'min',
    );
    result.quantity = 1;
    if (product.account.availableStock < (result.quantity * result.conversionFactor)) {
      DialogManager.showInfoDialog(context, "No hay stock disponible");
      viewController.requestSearchFocus();
      return;
    }
    viewController.quickAddItem(result);
  }

  Future<void> _openProduct(BuildContext context, ProductInDbInBranch product) async {
    final viewController = SaleTerminalTabletMediator.of(context).viewController;
    final res = await showCommercialProductDialog(
      context,
      product: product,
      defaultPriceLevel: viewController.selectedPriceLevel,
      preferredUnitType: viewController.isWholesale ? 'max' : 'min',
    );
    if (!context.mounted) return;
    if (res == null) {
      viewController.requestSearchFocus();
      return;
    }
    if (res.product.account.availableStock == 0 ||
        res.product.account.availableStock < (res.quantity * res.conversionFactor)) {
      DialogManager.showInfoDialog(context, "No hay stock disponible");
      viewController.requestSearchFocus();
      return;
    }
    if (res.quantity == 0) {
      viewController.requestSearchFocus();
      return;
    }
    viewController.addItem(res);
    viewController.requestSearchFocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewController = SaleTerminalTabletMediator.of(context).viewController;

    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: Card(
        margin: EdgeInsets.zero,
        child: BlocBuilder<ReadTerminalProductCubit, ReadTerminalProductState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is ReadTerminalProductLoading || state is ReadTerminalProductSearching)
                  const LinearProgressIndicator(minHeight: 3),
                Expanded(
                  child: _buildContent(context, state, viewController),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReadTerminalProductState state,
    SaleTerminalViewController viewController,
  ) {
    return switch (state) {
      ReadTerminalProductInitial() || ReadTerminalProductLoading() =>
        const Center(child: CircularProgressIndicator()),
      ReadTerminalProductError(:final message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => context.read<ReadTerminalProductCubit>().loadProducts(),
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      ReadTerminalProductSuccess(:final products) =>
        _buildProductGrid(context, products, viewController),
    };
  }

  Widget _buildProductGrid(
    BuildContext context,
    List<ProductInDbInBranch> products,
    SaleTerminalViewController viewController,
  ) {
    final categories = <String>{
      for (final product in products)
        if (product.categoryName != null && product.categoryName!.isNotEmpty) product.categoryName!,
    }.toList()..sort();

    final filtered = _selectedCategory == null
        ? products
        : products.where((p) => p.categoryName == _selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text("Todos", style: TextStyle(fontSize: 12)),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  for (final category in categories) ...[
                    const SizedBox(width: 4),
                    ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(category, style: const TextStyle(fontSize: 12)),
                      selected: _selectedCategory == category,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text("No se encontraron productos"))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = (constraints.maxWidth / 190).floor().clamp(2, 5);
                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(6),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return TerminalProductTile(
                          product: product,
                          priceLevelListenable: viewController,
                          onTap: () => _quickAdd(context, product),
                          onLongPress: () => _openProduct(context, product),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
