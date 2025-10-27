import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/expiration_logs/web/expiration_logs_screen_web.dart';

import 'cubit/read_expiration_log_cubit.dart';
import 'cubit/write_expiration_log_cubit.dart';

class ExpirationLogsScreen extends StatelessWidget {
  const ExpirationLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expirationLogRepo = context.read<ExpirationLogsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WriteExpirationLogCubit(
            expirationLogsRepository: expirationLogRepo,
          ),
        ),
        BlocProvider(
          create: (_) => ReadExpirationLogCubit(
            expirationLogsRepository: expirationLogRepo,
          )..loadAllExpirationLogs(),
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
    return const ExpirationLogsScreenWeb();
  }
}
