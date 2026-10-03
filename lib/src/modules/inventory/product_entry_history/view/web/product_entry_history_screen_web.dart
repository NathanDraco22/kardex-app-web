import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/inventory/product_entry_history/cubit/read_product_entry_history_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/entry_history_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class ProductEntryHistoryScreenWeb extends StatelessWidget {
  const ProductEntryHistoryScreenWeb({super.key});

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
      appBar: AppBar(title: const Text("Historial de Entradas por Producto")),
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
            _HeaderSection(),
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
