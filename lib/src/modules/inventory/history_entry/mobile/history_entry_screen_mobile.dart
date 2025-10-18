import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/cubit/read_entry_history_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/super_widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_app_front/widgets/dialogs/entry_history_viewer.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class HistoryEntryScreenMobile extends StatelessWidget {
  const HistoryEntryScreenMobile({super.key});

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
        padding: EdgeInsets.all(4.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 210,
              child: _HeaderSection(),
            ),
            Expanded(child: _ContentSection()),
          ],
        ),
      ),
    );
  }
}
