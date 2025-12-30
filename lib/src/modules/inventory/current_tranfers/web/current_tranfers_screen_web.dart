import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/transfers/read_transfers_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/current_tranfers/transfer_detail/transfer_detail_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/current_tranfers/widget/tranfer_status_badge.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class CurrentTranfersScreenWeb extends StatelessWidget {
  const CurrentTranfersScreenWeb({super.key});

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
        title: const Text("Transferencias"),
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
          children: [
            SizedBox(
              height: 100,
              child: _HeaderSection(),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
