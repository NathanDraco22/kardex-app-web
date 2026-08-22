part of '../sale_terminal_screen_web.dart';

class _CartSection extends StatefulWidget {
  const _CartSection();

  @override
  State<_CartSection> createState() => _CartSectionState();
}

class _CartSectionState extends State<_CartSection> {
  final ScrollController _scrollController = ScrollController();
  int _lastItemCount = 0;

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
    final viewController = SaleTerminalWebMediator.of(context).viewController;

    return Focus(
      canRequestFocus: false,
      descendantsAreFocusable: false,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8),
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
                      TextButton.icon(
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
                        ? const _EmptyCart()
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
                  _TotalsSummary(viewController: viewController),
                  const SizedBox(height: 10),
                  _PayButton(viewController: viewController),
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
    final res = await showCommercialProductDialog(
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

class _PayButton extends StatelessWidget {
  const _PayButton({required this.viewController});

  final SaleTerminalViewController viewController;

  @override
  Widget build(BuildContext context) {
    final hasItems = viewController.items.isNotEmpty;
    final hasZeroPrice = viewController.hasZeroPriceItems;
    final hasZeroQuantity = viewController.hasItemsWithZeroQuantity;
    final enabled = hasItems && !hasZeroPrice && !hasZeroQuantity;

    String? disabledMessage;
    if (hasZeroPrice) {
      disabledMessage = "Hay productos con precio en 0. Edítalos o elimínalos para cobrar.";
    } else if (hasZeroQuantity) {
      disabledMessage = "Hay productos sin cantidad. Revisa la venta antes de cobrar.";
    }

    return Tooltip(
      message: disabledMessage ?? "",
      child: CtrlKeyTip(
        hotKey: "G",
        onShortcut: () async {
          await startTerminalPayment(context);
          if (context.mounted) {
            viewController.requestSearchFocus();
          }
        },
        child: SizedBox(
          height: 64,
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: enabled
                ? () async {
                    await startTerminalPayment(context);
                    if (context.mounted) {
                      viewController.requestSearchFocus();
                    }
                  }
                : null,
            icon: const Icon(Icons.payments_outlined, size: 28),
            label: const Text("Cobrar"),
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              "Venta vacía",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Toca un producto para agregarlo",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsSummary extends StatelessWidget {
  const _TotalsSummary({required this.viewController});

  final SaleTerminalViewController viewController;

  @override
  Widget build(BuildContext context) {
    final totalAmount = viewController.totalAmount;
    final totalDiscount = viewController.totalDiscount;
    final subTotal = totalAmount + totalDiscount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Subtotal", style: TextStyle(color: Colors.grey)),
            Text(NumberFormatter.convertToMoneyLike(subTotal)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Descuento", style: TextStyle(color: Colors.grey)),
            Text(
              "-${NumberFormatter.convertToMoneyLike(totalDiscount)}",
              style: TextStyle(color: Colors.red.shade600),
            ),
          ],
        ),
        const Divider(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(totalAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
