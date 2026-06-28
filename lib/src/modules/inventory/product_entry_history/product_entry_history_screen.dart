import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/inventory/product_entry_history/cubit/read_product_entry_history_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/product_entry_history/view/web/product_entry_history_screen_web.dart';
import 'package:kardex_app_front/src/modules/inventory/product_entry_history/view/mobile/product_entry_history_screen_mobile.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

class ProductEntryHistoryScreen extends StatelessWidget {
  const ProductEntryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entryHistoriesRepo = context.read<EntryHistoriesRepository>();
    return BlocProvider(
      create: (context) => ReadProductEntryHistoryCubit(
        entryHistoriesRepository: entryHistoriesRepo,
      ),
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
    final isMobile = context.isMobile();

    if (isMobile) return const ProductEntryHistoryScreenMobile();

    return const ProductEntryHistoryScreenWeb();
  }
}
