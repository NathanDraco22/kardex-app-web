import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/adjust_exit_history/read_adjust_exit_history_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_exits_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/history/web/adjust_exit_history_web_screen.dart';

class AdjustExitHistoryScreen extends StatelessWidget {
  const AdjustExitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adjustRepo = context.read<AdjustExitsRepository>();

    return BlocProvider(
      create: (context) => ReadAdjustExitHistoryCubit(adjustRepo)..loadAdjustExitsHistory(),
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
    return const AdjustExitHistoryWebScreen();
  }
}
