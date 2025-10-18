import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/history_exit/cubit/read_exit_history_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/cubit/read_exit_doc_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/exit_history_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class HistoryExitScreenWeb extends StatelessWidget {
  const HistoryExitScreenWeb({super.key});

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
        title: const Text("Historial de Salidas"),
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
              height: 160,
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
