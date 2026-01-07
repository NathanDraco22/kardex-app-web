import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/cubit/read_current_inventory_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class CurrentInventoryScreenWeb extends StatelessWidget {
  const CurrentInventoryScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadCurrentInventoryCubit>();
    final state = readCubit.state;

    if (state is ReadCurrentInventoryLoading || state is ReadCurrentInventoryInitial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is ReadCurrentInventoryError) {
      return Scaffold(
        appBar: AppBar(title: const Text("Inventario Actual")),
        body: Center(child: Text(state.message)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Inventario Actual")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadCurrentInventoryCubit>();
    final state = readCubit.state as ReadCurrentInventorySuccess;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 100,
              child: _HeaderSection(),
            ),
            Expanded(
              child: Card(
                child: _ContentSection(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
