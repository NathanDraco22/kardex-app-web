import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/mediator.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/src/tools/search_product_dialog.dart';
import 'package:kardex_app_front/widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class InventoryEntryScreen extends StatelessWidget {
  const InventoryEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InventoryEntryMediator(child: const _RootScaffold());
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
    return const EntryTableForm(
      child: Center(
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
      ),
    );
  }
}

class EntryTableForm extends StatefulWidget {
  const EntryTableForm({super.key, required this.child});

  final Widget child;

  @override
  State<EntryTableForm> createState() => EntryTableFormState();
}

class EntryTableFormState extends State<EntryTableForm> {
  InnerRowsState? _innerRowsState;

  void registerInnerRowsState(InnerRowsState state) => _innerRowsState = state;
  void unregisterInnerRowsState() => _innerRowsState = null;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
