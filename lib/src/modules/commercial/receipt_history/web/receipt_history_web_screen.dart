import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/cubits/receipt_history/read_receipt_history_cubit.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/simple_search_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class ReceiptHistoryWebScreen extends StatelessWidget {
  const ReceiptHistoryWebScreen({super.key});

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
        title: const Text("Historial de Recibos"),
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
              height: 180,
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
