import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'cubit/read_exit_history_cubit.dart';
import 'mobile/history_exit_screen_mobile.dart';
import 'web/history_exit_screen_web.dart';

class HistoryExitScreen extends StatelessWidget {
  const HistoryExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exitHistoryRepo = context.read<ExitHistoriesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadExitHistoryCubit(
            exitHistoriesRepository: exitHistoryRepo,
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
      return const HistoryExitScreenMobile();
    }
    return const HistoryExitScreenWeb();
  }
}
