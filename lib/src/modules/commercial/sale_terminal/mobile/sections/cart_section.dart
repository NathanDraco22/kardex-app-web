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
          padding: const EdgeInsets.all(10),
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
                        onPressed: () => Navigator.of(context).maybePop(),
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
                            : () async {
                                final authState = getIt<AuthCubit>().state;
                                if (authState is! Authenticated) return;
                                final draft = viewController.exportToDraft();
                                await SaleTerminalDraftManager().saveDraft(authState.branch.id, draft);
                                _lastItemCount = 0;
                                viewController.clear();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Venta guardada en espera"),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        icon: Icon(
                          Icons.pause_circle_outline,
                          size: 20,
                          color: viewController.items.isEmpty ? Colors.grey.shade400 : Colors.amber.shade800,
                        ),
                      ),
                      IconButton(
                        tooltip: "Ver ventas en espera",
                        onPressed: () {
                          final authState = getIt<AuthCubit>().state;
                          if (authState is! Authenticated) return;
                          showHoldSalesDialog(
                            context,
                            branchId: authState.branch.id,
                            viewController: viewController,
                          );
                        },
                        icon: Icon(
                          Icons.history_toggle_off,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: viewController.items.isEmpty
                            ? null
                            : () async {
                                final confirm = await DialogManager.confirmActionDialog(
                                  context,
                                  "¿Estás seguro de que deseas vaciar todos los productos de la venta actual?",
                                );
                                if (confirm != true) return;
                                _lastItemCount = 0;
                                viewController.clear();
                              },
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: const Text("Vaciar"),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: viewController.items.isEmpty
                        ? const _MobileEmptyCart()
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: viewController.items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 4),
                            itemBuilder: (context, index) {
                              final item = viewController.items[index];
                              final color = index.isOdd ? Colors.white : Colors.grey.shade100;
                              return _MobileCartRow(
                                key: ValueKey(item),
                                color: color,
                                item: item,
                                onRemove: () => viewController.removeItem(item),
                                onEdit: () => _editItem(context, viewController, item),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  _MobileTotalsSummary(viewController: viewController),
                  const SizedBox(height: 8),
                  _MobilePayButton(viewController: viewController),
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

class _MobilePayButton extends StatelessWidget {
  const _MobilePayButton({required this.viewController});

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
          height: 52,
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
                fontSize: 18,
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
            icon: const Icon(Icons.payments_outlined, size: 22),
            label: const Text("Cobrar"),
          ),
        ),
      ),
    );
  }
}

class _MobileEmptyCart extends StatelessWidget {
  const _MobileEmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 44,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            const Text(
              "Venta vacía",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Toca un producto para agregarlo",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCartRow extends StatelessWidget {
  const _MobileCartRow({
    super.key,
    required this.color,
    required this.item,
    required this.onRemove,
    required this.onEdit,
  });

  final Color color;
  final CommercialProductResult item;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final unitPrice = NumberFormatter.convertToMoneyLike(
      item.newPrice * item.conversionFactor,
    );
    final total = NumberFormatter.convertToMoneyLike(item.total);
    final maxQuantity = item.product.account.availableStock ~/ item.conversionFactor;

    return Material(
      color: Colors.transparent,
      child: Ink(
        color: color,
        padding: const EdgeInsets.all(6),
        child: InkWell(
          canRequestFocus: false,
          onLongPress: () async {
            final box = context.findRenderObject() as RenderBox?;
            final position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
            final size = box?.size ?? Size.zero;
            final anchor = position + size.center(Offset.zero);
            final action = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(
                anchor.dx,
                anchor.dy,
                anchor.dx,
                anchor.dy,
              ),
              items: const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    title: Text("Editar"),
                    leading: Icon(Icons.edit_outlined),
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: ListTile(
                    title: Text("Eliminar"),
                    leading: Icon(Icons.delete_outline),
                  ),
                ),
              ],
            );
            if (!context.mounted) return;
            if (action == 'edit') onEdit();
            if (action == 'remove') onRemove();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageViewerWidget(
                    imageUrls: item.product.image.isNotEmpty ? [item.product.image] : [],
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              item.product.displayCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            UnitDisplayer(
                              unitName: item.selectedUnitName,
                              conversionFactor: item.conversionFactor,
                              fallbackUnitName: item.product.unitName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              unitPrice,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  FilledButton(
                    onPressed: item.quantity > 0
                        ? () {
                            item.quantity--;
                            SaleTerminalMobileMediator.of(context).viewController.refresh();
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Icon(Icons.remove, size: 14),
                  ),
                  SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: item.quantity < maxQuantity
                        ? () {
                            item.quantity++;
                            SaleTerminalMobileMediator.of(context).viewController.refresh();
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(32, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      total,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileTotalsSummary extends StatelessWidget {
  const _MobileTotalsSummary({required this.viewController});

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
            const Text(
              "Subtotal",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(subTotal),
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Descuento",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Text(
              "-${NumberFormatter.convertToMoneyLike(totalDiscount)}",
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Divider(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              NumberFormatter.convertToMoneyLike(totalAmount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
