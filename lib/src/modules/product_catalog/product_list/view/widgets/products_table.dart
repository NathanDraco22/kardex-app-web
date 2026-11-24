import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/read_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/dialogs/create_product_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/product_type_badge.dart';
import 'package:kardex_app_front/widgets/super_widgets/image_viewer_widget.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/status_tag_label.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

class ProductsTable extends StatelessWidget {
  const ProductsTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadProductCubit>();
    final state = cubit.state as ReadProductSuccess;
    final headerStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: Colors.grey.shade700,
    );

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 340,
                  child: SearchFieldDebounced(
                    onSearch: (value) {
                      cubit.searchProductByKeyword(value);
                    },
                  ),
                ),
                const Spacer(),
                SegmentedButton<ProductType?>(
                  segments: const [
                    ButtonSegment<ProductType?>(value: null, label: Text("Todos")),
                    ButtonSegment<ProductType?>(value: ProductType.item, label: Text("Artículos")),
                    ButtonSegment<ProductType?>(value: ProductType.nonInventory, label: Text("No inv.")),
                    ButtonSegment<ProductType?>(value: ProductType.service, label: Text("Servicios")),
                  ],
                  selected: {cubit.selectedTypeFilter},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      cubit.setTypeFilter(selection.first);
                    }
                  },
                ),
              ],
            ),
          ),

          if (state is ReadProductSearching) const LinearProgressIndicator(),

          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("Producto", style: headerStyle),
                ),
                Expanded(
                  child: Text("Marca", style: headerStyle),
                ),
                Expanded(
                  child: Text("Unidad", style: headerStyle),
                ),
                Expanded(
                  child: Text("Categoría", style: headerStyle),
                ),
                Expanded(
                  child: Center(child: Text("Estado", style: headerStyle)),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          Expanded(
            child: state.products.isEmpty
                ? const Center(
                    child: NoItemWidget(
                      icon: Icons.qr_code,
                      text: "No se encontraron productos",
                    ),
                  )
                : const _InnerRows(),
          ),

          _TableFooter(
            totalCount: state.products.length,
            isSearching: state is ReadProductSearching,
            hasMore: !cubit.isLastPage && state.products.isNotEmpty,
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

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xFFE2E8F0),
      ),
      itemBuilder: (context, index) {
        final currentProduct = products[index];

        Color rowColor = RowColorTool.getRowColor(index);

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

  Future<void> _openEditor(BuildContext context) async {
    final res = await showCreateProductDialog(context, product: product);
    if (res == null) return;
    if (!context.mounted) return;
    await context.read<ReadProductCubit>().markProductUpdated(res);
  }

  @override
  Widget build(BuildContext context) {
    final brand = product.brandName.trim();
    final category = product.categoryName?.trim() ?? "";

    return Material(
      color: color,
      child: InkWell(
        onTap: () => _openEditor(context),
        hoverColor: Colors.indigo.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    ImageViewerWidget(
                      imageUrls: product.image.isNotEmpty ? [product.image] : const [],
                      width: 48,
                      height: 48,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.qr_code,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.displayCode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              if (product.altCode.trim().isNotEmpty)
                                Text(
                                  "• Alt: ${product.altCode.trim()}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
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
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  brand.isEmpty ? "--" : brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: brand.isEmpty ? Colors.grey.shade500 : const Color(0xFF334155),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  product.defaultUnitName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF334155)),
                ),
              ),
              Expanded(
                child: Text(
                  category.isEmpty ? "--" : category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: category.isEmpty ? Colors.grey.shade500 : const Color(0xFF334155),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: StatusTagLabel(
                    label: product.isActive ? "Activo" : "Inactivo",
                    isActive: product.isActive,
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: "Editar producto",
                    onPressed: () => _openEditor(context),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({
    required this.totalCount,
    required this.isSearching,
    required this.hasMore,
  });

  final int totalCount;
  final bool isSearching;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Text(
            "Productos mostrados: $totalCount",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          if (isSearching)
            Text(
              "Buscando...",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          else if (hasMore)
            Text(
              "Desliza hacia abajo para cargar más",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}
