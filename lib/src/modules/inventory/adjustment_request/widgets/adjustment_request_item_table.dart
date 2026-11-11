import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_item_formatters.dart';

class AdjustmentRequestItemTable extends StatelessWidget {
  const AdjustmentRequestItemTable({
    super.key,
    required this.items,
    required this.entryTotal,
    required this.exitTotal,
  });

  final List<AdjustmentRequestItem> items;
  final int entryTotal;
  final int exitTotal;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const _HeaderTable(),
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        'La solicitud no tiene productos.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _ItemTableRow(
                          item: items[index],
                          index: index,
                        );
                      },
                    ),
            ),
            const Divider(height: 0.0),
            _TableFooter(
              productCount: items.length,
              entryTotal: entryTotal,
              exitTotal: exitTotal,
            ),
          ],
        ),
      ),
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
            flex: 3,
            fit: FlexFit.tight,
            child: Text(
              'Nombre del Producto',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                'Existencia',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                'Conteo Real',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                'Diferencia',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                'Costo Unitario',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                'Subtotal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTableRow extends StatelessWidget {
  const _ItemTableRow({
    required this.item,
    required this.index,
  });

  final AdjustmentRequestItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final factor = UnitConversionTool.ensureSafeFactor(item.conversionFactor);
    final unitName = item.unitName ?? item.standardUnitName ?? '';
    final countedBase = item.countedQuantity;

    return Container(
      height: 75,
      color: RowColorTool.getRowColor(index),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Producto
          Flexible(
            flex: 3,
            fit: FlexFit.tight,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (factor > 1) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                unitName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if ((item.code ?? '').isNotEmpty) ...[
                            Text(
                              item.code!,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if ((item.brandName ?? '').isNotEmpty)
                            Text(
                              item.brandName!,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Existencia
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatAdjustmentDisplayQuantity(item.systemStock, factor),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (factor > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      '= ${item.systemStock} ${item.standardUnitName ?? ""}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Conteo Real
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatAdjustmentDisplayQuantity(item.countedQuantity, factor),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (factor > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      '= $countedBase ${item.standardUnitName ?? ""}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Diferencia
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    adjustmentDifferenceIcon(item.difference),
                    size: 16,
                    color: adjustmentDifferenceColor(item.difference),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      formatAdjustmentSignedQuantity(item.difference, factor),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: adjustmentDifferenceColor(item.difference),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Costo Unitario
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    NumberFormatter.convertToMoneyLike(item.cost),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (factor > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Base: ${NumberFormatter.convertToMoneyLike((item.cost / factor).round())}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Subtotal
          Flexible(
            fit: FlexFit.tight,
            child: Center(
              child: Text(
                NumberFormatter.convertToMoneyLike(item.subtotal),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({
    required this.productCount,
    required this.entryTotal,
    required this.exitTotal,
  });

  final int productCount;
  final int entryTotal;
  final int exitTotal;

  @override
  Widget build(BuildContext context) {
    final netTotal = entryTotal - exitTotal;

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Text(
            'Productos: $productCount',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const Spacer(),
          const Text(
            'Sobrante: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(entryTotal),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Faltante: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(exitTotal),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 24),
          const Text(
            'Total Neto: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(netTotal),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: netTotal >= 0 ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
