import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/receipt_history/read_receipt_history_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/receipt_history/web/receipt_history_web_screen.dart';

class ReceiptHistoryScreen extends StatelessWidget {
  const ReceiptHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final receiptRepo = context.read<ReceiptsRepository>();

    return BlocProvider(
      create: (context) => ReadReceiptHistoryCubit(receiptRepo)..loadReceiptsHistory(),
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
    return const ReceiptHistoryWebScreen();
  }
}
