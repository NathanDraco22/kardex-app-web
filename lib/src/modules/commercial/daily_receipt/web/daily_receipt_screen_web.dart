import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_receipt/cubit/read_daily_receipt_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/super_widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_app_front/widgets/dialogs/receipt_viewer.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class DailyReceiptScreenWeb extends StatelessWidget {
  const DailyReceiptScreenWeb({super.key});

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
      appBar: AppBar(title: const Text("Historial de Recibos Diarios")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry mainPadding = const EdgeInsets.all(8.0);

    if (context.isMobile()) {
      mainPadding = EdgeInsets.zero;
    }

    return Center(
      child: Padding(
        padding: mainPadding,
        child: const Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
