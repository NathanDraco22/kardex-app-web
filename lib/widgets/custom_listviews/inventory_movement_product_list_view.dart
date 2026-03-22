import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/calculator/calculator_field.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/custom_product_search_delegate.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class ProductRowCard {
  ProductRowCard({
    required this.product,
    this.quantity = 0,
    this.unitaryCost = 0,
    this.editableCost = false,
    this.expirationDate,
    this.haveExpirationDate = true,
  });

  ProductInDb product;
  int quantity = 0;
  int unitaryCost = 0;
  DateTime? expirationDate;

  bool editableCost;
  bool haveExpirationDate;

  int get subTotal => (quantity * unitaryCost);
}

class ProductListViewController extends ChangeNotifier {
  List<ProductRowCard> rowCards = [];

  int get total => rowCards.fold<int>(
    0,
    (previousValue, element) => previousValue + element.subTotal,
  );

  bool get hasRowCards => rowCards.isNotEmpty;

  void refresh() => notifyListeners();

  void clear() {
    rowCards.clear();
    notifyListeners();
  }

  void addRowCard(ProductRowCard newRow) {
    final isAlreadyExists = rowCards.any(
      (oldRow) => oldRow.product.id == newRow.product.id,
    );
    if (isAlreadyExists) return;

    rowCards.add(newRow);
    notifyListeners();
  }

  void removeRowCard(ProductRowCard row) {
    rowCards.remove(row);
    notifyListeners();
  }

  void updateRowCard(ProductRowCard oldProductRow, ProductRowCard newProductRow) {
    final index = rowCards.indexOf(oldProductRow);
    rowCards[index] = newProductRow;
    notifyListeners();
  }
}

class _ListViewMediator extends InheritedNotifier<ProductListViewController> {
  const _ListViewMediator({
    required super.child,
    required super.notifier,
  });

  static _ListViewMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ListViewMediator>()!;
  }
}

class InventoryMovementProductListView extends StatefulWidget {
  const InventoryMovementProductListView({
    super.key,
    this.controller,
  });

  final ProductListViewController? controller;

  @override
  State<InventoryMovementProductListView> createState() => _InventoryMovementProductListViewState();
}

class _InventoryMovementProductListViewState extends State<InventoryMovementProductListView> {
  ProductListViewController? _listViewController;

  @override
  void initState() {
    _listViewController = widget.controller ?? ProductListViewController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _ListViewMediator(
      notifier: _listViewController!,
      child: const Card(
        child: _Content(),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final mediator = _ListViewMediator.of(context);
    final controller = mediator.notifier!;
    return Column(
      children: [
        ..._generateRowCards(context, controller),
      ],
    );
  }

  Iterable<Widget> _generateRowCards(BuildContext context, ProductListViewController controller) sync* {
    final rowCard = controller.rowCards;

    for (var i = 0; i < rowCard.length; i++) {
      final currentRowCardModel = rowCard[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield EntryRowCard(
        key: ValueKey(currentRowCardModel),
        rowColor: color,
        rowCardModel: currentRowCardModel,

        onRemove: () => controller.removeRowCard(currentRowCardModel),
        onChange: () async {
          final res = await showProductSearchDelegate(context);
          if (res == null) return;
          final newRow = ProductRowCard(
            product: res,
            quantity: 0,
            unitaryCost: 0,
            editableCost: true,
          );

          controller.updateRowCard(currentRowCardModel, newRow);
        },
      );
    }
  }
}

class EntryRowCard extends StatefulWidget {
  const EntryRowCard({
    super.key,
    required this.rowColor,
    required this.rowCardModel,
    this.onRemove,
    this.onChange,
  });

  final Color rowColor;
  final ProductRowCard rowCardModel;

  final VoidCallback? onRemove;
  final VoidCallback? onChange;

  @override
  State<EntryRowCard> createState() => _EntryRowCardState();
}

class _EntryRowCardState extends State<EntryRowCard> with AutomaticKeepAliveClientMixin {
  final focusNode = FocusNode();
  final expirationDateFocusNode = FocusNode();
  final parentFocus = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future(() {
      expirationDateFocusNode.requestFocus();
    });
  }

  Offset? offset;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final product = widget.rowCardModel.product;
    final rowCard = widget.rowCardModel;

    final subtotal = (widget.rowCardModel.quantity * widget.rowCardModel.unitaryCost);

    BoxBorder? border;
    if (parentFocus.hasFocus) {
      final color = Theme.of(context).colorScheme.primary;
      border = Border.all(color: color, width: 2);
    }

    return Focus(
      focusNode: parentFocus,
      onFocusChange: (value) {
        setState(() {});
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (details) {
            offset = details.globalPosition;
          },
          onLongPress: () async {
            if (offset == null) return;
            final res = await _showContextMenu(context, offset!);
            offset = null;
            if (res == null) return;
            switch (res) {
              case _MenuOptions.change:
                widget.onChange?.call();
              case _MenuOptions.delete:
                widget.onRemove?.call();
            }
          },
          child: Ink(
            decoration: BoxDecoration(
              color: widget.rowColor,
              border: border,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 16),
                              Text(
                                product.displayCode,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          product.unitName,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          product.brandName,
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    height: 4.0,
                    thickness: 2,
                    color: Colors.black12,
                  ),
                  if (rowCard.haveExpirationDate)
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: TitleTextField(
                            focusNode: expirationDateFocusNode,
                            inputFormatters: [MonthYearInputFormatter()],
                            titleTextAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            textInputAction: .next,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            title: "F. Vencimiento",
                            onChanged: (value) {
                              try {
                                final date = DateTimeTool.fromMMYY(value);
                                rowCard.expirationDate = date;
                              } catch (e) {
                                rowCard.expirationDate = null;
                              }
                            },
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: TitleTextField(
                          focusNode: focusNode,
                          inputFormatters: [IntegerTextInputFormatter()],
                          titleTextAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          onEditingComplete: () => FocusScope.of(context).nextFocus(),
                          title: "Cantidad",
                          onChanged: (value) {
                            if (value.isEmpty) {
                              rowCard.quantity = 0;
                              setState(() {});
                              return;
                            }
                            final numValue = int.tryParse(value);
                            if (numValue == null) return;
                            rowCard.quantity = numValue;
                            setState(() {});
                          },
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Builder(
                          builder: (context) {
                            final formattedCost = (rowCard.unitaryCost / 100).toStringAsFixed(2);
                            if (!rowCard.editableCost) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Text("Costo Unitario"),
                                    const SizedBox(height: 6),
                                    Text(
                                      formattedCost,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              spacing: 6,
                              children: [
                                const Text("Costo Unitario"),
                                CalculatorField(
                                  onDone: (value) {
                                    if (value.isEmpty) {
                                      rowCard.unitaryCost = 0;
                                      setState(() {});
                                      return;
                                    }
                                    final numValue = double.tryParse(value);
                                    if (numValue == null) return;
                                    final minimalUnit = (numValue * 100).round();
                                    rowCard.unitaryCost = minimalUnit;
                                    setState(() {});
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  DefaultTextStyle(
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            "Subtotal: ",
                            textAlign: TextAlign.end,
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            NumberFormatter.convertToMoneyLike(subtotal.toInt()),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _MenuOptions { change, delete }

Future<_MenuOptions?> _showContextMenu(BuildContext context, Offset position) async {
  final result = await showMenu<_MenuOptions>(
    context: context,
    position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
    items: [
      const PopupMenuItem(
        value: _MenuOptions.change,
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text('Cambiar'),
        ),
      ),
      const PopupMenuItem(
        value: _MenuOptions.delete,
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text('Eliminar'),
        ),
      ),
    ],
  );

  if (result != null) {
    return result;
  }

  return null;
}
