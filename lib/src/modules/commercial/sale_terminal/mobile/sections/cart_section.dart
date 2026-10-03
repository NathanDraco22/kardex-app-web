part of '../sale_terminal_screen_mobile.dart';

class _MobileCartSection extends StatefulWidget {
  const _MobileCartSection();

  @override
  State<_MobileCartSection> createState() => _MobileCartSectionState();
}

class _MobileCartSectionState extends State<_MobileCartSection> {
  final ScrollController _scrollController = ScrollController();
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewController = SaleTerminalMobileMediator.of(context).viewController;

    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListenableBuilder(
            listenable: viewController,
            builder: (context, _) {
              if (viewController.items.length > _lastItemCount) {
                _scrollToBottom();
              }
              _lastItemCount = viewController.items.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: "Cerrar",
                        onPressed: () => Scaffold.of(context).closeEndDrawer(),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "Venta actual (${viewController.totalQuantity})",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: "Poner venta en espera",
                        onPressed: viewController.items.isEmpty
                            ? null
                            : () => holdTerminalSale(
                                context,
                                viewController: viewController,
                                onHoldCompleted: () => _lastItemCount = 0,
                              ),
                        icon: Icon(
                          Icons.pause_circle_outline,
                          size: 20,
                          color: viewController.items.isEmpty ? Colors.grey.shade400 : Colors.amber.shade800,
                        ),
                      ),
                      IconButton(
                        tooltip: "Ver ventas en espera",
                        onPressed: () => openHoldSalesModal(context, viewController: viewController),
                        icon: Icon(
                          Icons.history_toggle_off,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SecondaryMenuButton(
                        onPressed: viewController.items.isEmpty
                            ? null
                            : () => confirmAndClearCart(
                                context,
                                viewController: viewController,
                                onCleared: () => _lastItemCount = 0,
                              ),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: const Text("Vaciar"),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: viewController.items.isEmpty
                        ? const TerminalEmptyCart(
                            iconSize: 44,
                            titleFontSize: 14,
                            subtitleFontSize: 12,
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: viewController.items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final item = viewController.items[index];
                              final color = index.isOdd ? Colors.white : Colors.grey.shade50;
                              final maxQuantity = item.product.account.availableStock ~/ item.conversionFactor;
                              return TerminalCartItemTile(
                                key: ValueKey(item),
                                item: item,
                                backgroundColor: color,
                                onRemove: () => viewController.removeItem(item),
                                onEdit: () => _editItem(context, viewController, item),
                                onQuantityIncrement: item.quantity < maxQuantity
                                    ? () {
                                        item.quantity++;
                                        viewController.refresh();
                                      }
                                    : null,
                                onQuantityDecrement: item.quantity > 0
                                    ? () {
                                        item.quantity--;
                                        viewController.refresh();
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  TerminalTotalsSummary(
                    viewController: viewController,
                    totalFontSize: 18,
                    labelFontSize: 13,
                  ),
                  const SizedBox(height: 8),
                  TerminalPayButton(
                    viewController: viewController,
                    height: 52,
                    fontSize: 18,
                    iconSize: 22,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _editItem(
    BuildContext context,
    SaleTerminalViewController viewController,
    CommercialProductResult item,
  ) async {
    final res = await showCommercialProductModal(
      context,
      product: item.product,
      commercialProductResult: item,
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
    viewController.updateItem(item, res);
    viewController.requestSearchFocus();
  }
}
