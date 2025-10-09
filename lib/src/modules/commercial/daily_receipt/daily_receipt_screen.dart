import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_receipt/cubit/read_daily_receipt_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_receipt/web/daily_receipt_screen_web.dart';

class DailyReceiptScreen extends StatelessWidget {
  const DailyReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final receiptRepo = context.read<ReceiptsRepository>();
    return BlocProvider(
      create: (context) => ReadDailyReceiptsCubit(
        receiptsRepository: receiptRepo,
      )..loadDailyReceipts(),
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
    return const DailyReceiptScreenWeb();
  }
}
