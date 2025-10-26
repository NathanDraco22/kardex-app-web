import 'package:flutter/material.dart';

class BasicTableColumn {
  final Widget label;
  final int flex;

  BasicTableColumn({
    required this.label,
    this.flex = 1,
  });
}

class BasicTableCell {
  Widget content;

  BasicTableCell({
    required this.content,
  });
}

class BasicTableRow {
  BasicTableRow({
    required this.cells,
    this.onTap,
    this.color = Colors.white,
  });

  List<BasicTableCell> cells;
  Color color;
  VoidCallback? onTap;
}

class BasicTableListView extends StatelessWidget {
  const BasicTableListView({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.rowBuilder,
    this.controller,
  });

  final List<BasicTableColumn> columns;
  final ScrollController? controller;

  final int itemCount;
  final BasicTableRow? Function(BuildContext context, int index) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                for (final column in columns)
                  Expanded(
                    flex: column.flex,
                    child: column.label,
                  ),
              ],
            ),
          ),
          const Divider(
            height: 0.0,
            thickness: 2.0,
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                final tableRow = rowBuilder.call(context, index);
                if (tableRow == null) {
                  return null;
                }

                if (columns.length != tableRow.cells.length) {
                  return Ink(
                    key: ValueKey(index),
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Invalid row $index length: ${tableRow.cells.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    hoverColor: Colors.amber.shade100,
                    onTap: tableRow.onTap,
                    child: Ink(
                      color: tableRow.color,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          for (var i = 0; i < tableRow.cells.length; i++)
                            Expanded(
                              flex: columns[i].flex,
                              child: tableRow.cells[i].content,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
