import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/cubit/read_current_inventory_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/mobile/current_inventory_screen_mobile.dart';
import 'package:kardex_app_front/src/modules/inventory/current_inventory/web/current_inventory_screen_web.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

class CurrentInventoryScreen extends StatelessWidget {
  const CurrentInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventoryRepo = context.read<InventoriesRepository>();
    return BlocProvider(
      create: (context) => ReadCurrentInventoryCubit(
        inventoriesRepository: inventoryRepo,
      )..loadAllInventories(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    if (context.isMobile()) {
      return const CurrentInventoryScreenMobile();
    }
    return const CurrentInventoryScreenWeb();
  }
}
