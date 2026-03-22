import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/product_transaction/product_transaction.dart';
import 'package:kardex_app_front/src/modules/inventory/product_movements/cubit/read_product_transaction_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/show_doc_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class CommercialProductMovementsScreenWeb extends StatelessWidget {
  const CommercialProductMovementsScreenWeb({super.key});

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
      appBar: AppBar(title: const Text("Movimientos de Productos")),
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
              height: 100,
              child: _HeaderSection(),
            ),
            Expanded(
              child: Card(
                child: _ContentSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
