import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/mediator.dart';
import 'package:kardex_app_front/src/tools/search_product_dialog.dart';
import 'package:kardex_app_front/widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class InventoryEntryScreen extends StatefulWidget {
  const InventoryEntryScreen({super.key});

  @override
  State<InventoryEntryScreen> createState() => _InventoryEntryScreenState();
}

class _InventoryEntryScreenState extends State<InventoryEntryScreen> {
  final InventoryEntryNotifier notifier = InventoryEntryNotifier();
  @override
  Widget build(BuildContext context) {
    return InventoryEntryMediator(
      notifier: notifier,
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entrada de Inventario")),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: _HeaderSection(),
            ),
            SizedBox(height: 8),
            Flexible(
              fit: FlexFit.tight,
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
