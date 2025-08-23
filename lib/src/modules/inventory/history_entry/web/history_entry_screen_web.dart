import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/cubit/read_entry_history_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class HistoryEntryScreenWeb extends StatelessWidget {
  const HistoryEntryScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de entradas"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: _HeaderSection(),
            ),
            Expanded(child: _ContentSection()),
          ],
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadEntryHistoryCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadEntryHistoryFiltering || state is ReadEntryHistoryLoading) {
                return const LinearProgressIndicator();
              }

              return const SizedBox.shrink();
            },
          ),

          Builder(
            builder: (context) {
              if (state is! ReadEntryHistorySuccess) {
                return const SizedBox.shrink();
              }

              final entryHistories = state.histories;

              return Expanded(
                child: BasicTableListView(
                  itemCount: entryHistories.length,
                  columns: [
                    BasicTableColumn(label: Text("Fecha"), flex: 1),
                    BasicTableColumn(label: Text("Proveedor"), flex: 1),
                    BasicTableColumn(label: Text("Documento"), flex: 1),
                    BasicTableColumn(label: Text("Total"), flex: 1),
                    BasicTableColumn(label: Text(""), flex: 1),
                  ],
                  rowBuilder: (context, index) {
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    final currentEntryHistory = entryHistories[index];
                    final currentDocDate = DateTimeTool.formatddMMyyyy(currentEntryHistory.docDate);
                    final totalInMoney = NumberFormatter.convertToMoneyLike(currentEntryHistory.total);

                    return BasicTableRow(
                      color: rowColor,
                      cells: [
                        BasicTableCell(
                          content: Text(currentDocDate),
                        ),
                        BasicTableCell(
                          content: Text(currentEntryHistory.supplier.name),
                        ),
                        BasicTableCell(
                          content: Text(currentEntryHistory.docNumber),
                        ),
                        BasicTableCell(
                          content: Text(totalInMoney),
                        ),
                        BasicTableCell(
                          content: const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
