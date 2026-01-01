import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/adjust_entry_history/read_adjust_entry_history_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_entries_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_entry/history/web/adjust_entry_history_web_screen.dart';

class AdjustEntryHistoryScreen extends StatelessWidget {
  const AdjustEntryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adjustRepo = context.read<AdjustEntriesRepository>();

    return BlocProvider(
      create: (context) => ReadAdjustEntryHistoryCubit(adjustRepo)..loadAdjustEntriesHistory(),
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
    return const AdjustEntryHistoryWebScreen();
  }
}
