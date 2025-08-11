part of '../inventory_entry_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            _HeaderTable(),
            Divider(),

            Expanded(
              child: _InnerRows(),
            ),
            Divider(height: 0.0),
            SizedBox(
              height: 40,
              child: _TableFooter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryEntryMediator.of(context);
    return Row(
      children: [
        const Flexible(
          fit: FlexFit.tight,
          flex: 2,
          child: SizedBox(),
        ),
        const Flexible(
          fit: FlexFit.tight,
          flex: 3,
          child: SizedBox(),
        ),
        const Flexible(
          fit: FlexFit.tight,
          child: Center(
            child: Text(
              "Total: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: mediator.sharedNotifiers.totalNotifier,
              builder: (context, value, child) {
                final total = value / 100;
                return Text(
                  "$defaultCoinSymbol ${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderTable extends StatelessWidget {
  const _HeaderTable();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Text("Nombre del Producto"),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Unidad")),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Marca")),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Cantidad")),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Costo Unitario")),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text("Subtotal")),
          ),
        ],
      ),
    );
  }
}

class RowViewModel {
  RowViewModel({
    required this.product,
  });

  ProductInDb product;
  int? quantity;
  int? unitaryCost;

  int get subTotal => (quantity ?? 0) * (unitaryCost ?? 0);
}

class _InnerRows extends StatefulWidget {
  const _InnerRows();

  @override
  State<_InnerRows> createState() => InnerRowsState();
}

class InnerRowsState extends State<_InnerRows> {
  EntryTableFormState? _entryTableFormState;
  InventoryEntryMediator get mediator => InventoryEntryMediator.of(context);
  @override
  void didChangeDependencies() {
    _entryTableFormState = context.findAncestorStateOfType<EntryTableFormState>();
    _entryTableFormState?.registerInnerRowsState(this);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entryTableFormState?.unregisterInnerRowsState();
    super.dispose();
  }

  List<RowViewModel> rows = [];

  @override
  Widget build(BuildContext context) {
    return NotificationListener<EntryRowNotification>(
      onNotification: (notification) {
        if (notification is EntryRowDeleteNotification) {
          rows.remove(notification.rowModel);
          setState(() {});
        }
        if (notification is EntryRowChangeNotification) {
          final product = notification.rowModel.product;
          showSearchProductDialog(context, product: product).then((result) {
            if (result == null) return;
            final index = rows.indexWhere((row) => row.product.id == product.id);
            if (index != -1) {
              rows[index].product = result;
              setState(() {});
            }
          });
        }
        return true;
      },
      child: ListView(
        addAutomaticKeepAlives: true,
        children: [
          ..._generateRows(),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final res = await showSearchProductDialog(context);
                  if (res == null) return;

                  final alreadyExists = rows.any(
                    (element) => element.product.id == res.id,
                  );
                  if (alreadyExists) return;

                  rows.add(RowViewModel(product: res));
                  setState(() {});
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Agregar Producto",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Iterable<EntryRow> _generateRows() sync* {
    for (var i = 0; i < rows.length; i++) {
      final currentRowModel = rows[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield EntryRow(
        key: ValueKey(currentRowModel.product),
        rowModel: currentRowModel,
        color: color,
        onSubtotalChanged: () {
          final total = rows.fold<int>(
            0,
            (previousValue, element) {
              return previousValue + element.subTotal;
            },
          );

          Future(
            () {
              mediator.sharedNotifiers.totalNotifier.value = total;
            },
          );
        },
      );
    }
  }
}

class EntryRow extends StatefulWidget {
  const EntryRow({
    super.key,
    required this.color,
    required this.rowModel,
    this.onSubtotalChanged,
  });

  final Color color;
  final RowViewModel rowModel;
  final void Function()? onSubtotalChanged;

  @override
  State<EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<EntryRow> with AutomaticKeepAliveClientMixin {
  final focusNode = FocusNode();

  int quantity = 0;
  int unitaryCost = 0;

  @override
  void initState() {
    super.initState();
    Future(
      () {
        focusNode.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final product = widget.rowModel.product;

    final subtotal = (quantity * unitaryCost) / 100;
    widget.onSubtotalChanged?.call();
    return Ink(
      color: widget.color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 48,
      child: Row(
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Row(
              children: [
                MoreActionRowButton(widget: widget),
                Text(product.name),
              ],
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text(product.unitName)),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(child: Text(product.brandName)),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: TextField(
                focusNode: focusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [IntegerTextInputFormatter()],
                textAlign: TextAlign.center,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                onChanged: (value) {
                  final numValue = int.tryParse(value);
                  if (numValue == null) return;
                  quantity = numValue;
                  widget.rowModel.quantity = quantity;
                  setState(() {});
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [DecimalTextInputFormatter()],
                textAlign: TextAlign.center,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                onChanged: (value) {
                  final numValue = double.tryParse(value);
                  if (numValue == null) return;
                  final minimalUnit = (numValue * 100).toInt();
                  unitaryCost = minimalUnit;
                  widget.rowModel.unitaryCost = unitaryCost;
                  setState(() {});
                },
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text("C\$ ${subtotal.toStringAsFixed(2)}"),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreActionRowButton extends StatelessWidget {
  const MoreActionRowButton({
    super.key,
    required this.widget,
  });

  final EntryRow widget;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          focusNode: FocusNode(skipTraversal: true),
          onPressed: () {
            final renderBox = context.findRenderObject() as RenderBox;

            final globalPosOffset = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                globalPosOffset.dx,
                globalPosOffset.dy + size.height,
                globalPosOffset.dx + size.width,
                globalPosOffset.dy + size.height,
              ),

              items: [
                PopupMenuItem(
                  child: const Text("Cambiar"),
                  onTap: () {
                    EntryRowChangeNotification(widget.rowModel).dispatch(context);
                  },
                ),
                PopupMenuItem(
                  child: const Text("Eliminar"),
                  onTap: () {
                    EntryRowDeleteNotification(widget.rowModel).dispatch(context);
                  },
                ),
              ],
            );
          },
          icon: const Icon(Icons.more_vert),
          splashRadius: 16,
        );
      },
    );
  }
}

class EntryRowNotification extends Notification {
  final RowViewModel rowModel;
  EntryRowNotification(this.rowModel);
}

class EntryRowDeleteNotification extends EntryRowNotification {
  EntryRowDeleteNotification(super.rowModel);
}

class EntryRowChangeNotification extends EntryRowNotification {
  EntryRowChangeNotification(super.rowModel);
}
