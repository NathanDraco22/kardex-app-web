import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_receipt/cubit/read_daily_receipt_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

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
