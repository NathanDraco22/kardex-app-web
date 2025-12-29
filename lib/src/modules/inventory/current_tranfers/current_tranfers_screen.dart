import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/transfers/read_transfers_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/current_tranfers/web/current_tranfers_screen_web.dart';

class CurrentTranfersScreen extends StatelessWidget {
  const CurrentTranfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transferRepo = context.read<TransfersRepository>();

    return BlocProvider(
      create: (context) => ReadTransfersCubit(
        transfersRepository: transferRepo,
      ),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const CurrentTranfersScreenWeb();
  }
}
