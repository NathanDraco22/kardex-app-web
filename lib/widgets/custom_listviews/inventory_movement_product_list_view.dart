import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class ProductRowCard {
  ProductRowCard({
    required this.product,
    this.quantity = 0,
    this.unitaryCost = 0,
    this.editableCost = false,
  });

  ProductInDb product;
  int quantity = 0;
  int unitaryCost = 0;

  bool editableCost;

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
        ..._generateRowCards(controller),
      ],
    );
  }

  Iterable<Widget> _generateRowCards(ProductListViewController controller) sync* {
    final rowCard = controller.rowCards;

    for (var i = 0; i < rowCard.length; i++) {
      final currentRowCardModel = rowCard[i];
      final color = i.isOdd ? Colors.white : Colors.grey.shade200;
      yield EntryRowCard(rowColor: color, rowCardModel: currentRowCardModel);
    }
  }
}

class EntryRowCard extends StatefulWidget {
  const EntryRowCard({
    super.key,
    required this.rowColor,
    required this.rowCardModel,
  });

  final Color rowColor;
  final ProductRowCard rowCardModel;

  @override
  State<EntryRowCard> createState() => _EntryRowCardState();
}

class _EntryRowCardState extends State<EntryRowCard> {
  final focusNode = FocusNode();
  final parentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future(() {
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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

                Row(
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
                      child: TitleTextField(
                        inputFormatters: [DecimalTextInputFormatter()],
                        titleTextAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        title: "Costo Unitario",
                        onChanged: (value) {
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
    );
  }
}
