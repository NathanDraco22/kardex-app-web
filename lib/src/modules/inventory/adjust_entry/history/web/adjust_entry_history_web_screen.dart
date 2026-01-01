import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/adjust_entry_history/read_adjust_entry_history_cubit.dart';
import 'package:kardex_app_front/src/domain/models/adjust_entry/adjust_entry_model.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_entries_repository.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/adjust_entry_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/simple_search_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class AdjustEntryHistoryWebScreen extends StatelessWidget {
  const AdjustEntryHistoryWebScreen({super.key});

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
        title: const Text("Historial de Entradas por Ajuste"),
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
        padding: EdgeInsets.all(4.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: _HeaderSection(),
            ),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
