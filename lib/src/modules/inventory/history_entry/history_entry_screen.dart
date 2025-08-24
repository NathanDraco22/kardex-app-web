import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/cubit/read_entry_history_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/history_entry/web/history_entry_screen_web.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'mobile/history_entry_screen_mobile.dart';

class HistoryEntryScreen extends StatelessWidget {
  const HistoryEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entryHistoryRepo = context.read<EntryHistoriesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadEntryHistoryCubit(
            entryHistoriesRepository: entryHistoryRepo,
          )..loadPaginatedHistories(),
        ),
      ],
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
      return const HistoryEntryScreenMobile();
    }

    return const HistoryEntryScreenWeb();
  }
}
