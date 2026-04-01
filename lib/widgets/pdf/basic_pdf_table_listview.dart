import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BasicPdfTableColumn {
  final pw.Widget label;
  final int flex;

  BasicPdfTableColumn({
    required this.label,
    this.flex = 1,
  });
}

class BasicPdfTableCell {
  pw.Widget content;

  BasicPdfTableCell({
    required this.content,
  });
}

class BasicPdfTableRow {
  BasicPdfTableRow({
    required this.cells,
    this.color = PdfColors.white,
  });

  List<BasicPdfTableCell> cells;
  PdfColor color;
}

class BasicPdfTableListView extends pw.StatelessWidget {
  BasicPdfTableListView({
    required this.columns,
    required this.itemCount,
    required this.rowBuilder,
  });

  final List<BasicPdfTableColumn> columns;
  final int itemCount;
  final BasicPdfTableRow? Function(pw.Context context, int index) rowBuilder;

  @override
  pw.Widget build(pw.Context context) {
    if (columns.isEmpty || itemCount == 0) return pw.SizedBox.shrink();

    final columnWidths = <int, pw.TableColumnWidth>{};
    for (var i = 0; i < columns.length; i++) {
      columnWidths[i] = pw.FlexColumnWidth(columns[i].flex.toDouble());
    }

    final headerDecorRows = pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 2.0, color: PdfColors.black),
        ),
      ),
      children: [
        for (final column in columns)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: column.label,
          ),
      ],
    );

    final List<pw.TableRow> rows = [headerDecorRows];

    for (var i = 0; i < itemCount; i++) {
      final tableRow = rowBuilder(context, i);
      if (tableRow == null) continue;

      if (columns.length != tableRow.cells.length) {
        rows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.red),
            children: [
              for (var c = 0; c < columns.length; c++)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: pw.Text(
                    "Error: Invalid row $i length",
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ),
            ],
          ),
        );
        continue;
      }

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: tableRow.color),
          children: [
            for (var j = 0; j < tableRow.cells.length; j++)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: tableRow.cells[j].content,
              ),
          ],
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8.0),
      child: pw.Table(
        columnWidths: columnWidths,
        children: rows,
      ),
    );
  }
}
