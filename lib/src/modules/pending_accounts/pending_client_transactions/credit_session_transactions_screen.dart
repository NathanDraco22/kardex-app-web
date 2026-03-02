import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/client_transaction/read_client_transaction_cubit.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_transaction_repository.dart';
import 'package:kardex_app_front/src/modules/finance/client_movements/view/widgets/movement_mobile_row.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

class CreditSessionTransactionsScreen extends StatelessWidget {
  const CreditSessionTransactionsScreen({super.key, required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final clientTransRepo = context.read<ClientTransactionsRepository>();
        final cubit = ReadClientTransactionCubit(transactionsRepository: clientTransRepo);

        cubit.loadPaginatedTransactions(
          client: client,
          startDate: client.lastCreditStart,
          endDate: client.updatedAt,
        );

        return cubit;
      },
      child: _RootScaffold(client: client),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transacciones de Sesión de Crédito")),
      body: _Body(client: client),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final maxScrollExtend = notification.metrics.maxScrollExtent;
        final scrollOffset = notification.metrics.pixels;
        final nextPageThreshold = maxScrollExtend * 0.65;

        if (scrollOffset >= nextPageThreshold) {
          context.read<ReadClientTransactionCubit>().getNextPage();
        }
        return false;
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 100,
                  child: _HeaderSection(client: client),
                ),
                const Expanded(
                  child: Card(
                    child: _ContentSection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.client});

  final ClientInDb client;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "${client.id} - ${client.name}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (client.lastCreditStart != null) Text("Desde: ${DateTimeTool.formatddMMyy(client.lastCreditStart!)}"),
          ],
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: ScrollController(), // Provide a distinct ScrollController internally
      child: BlocBuilder<ReadClientTransactionCubit, ReadClientTransactionState>(
        builder: (context, state) {
          if (state is ReadClientTransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReadClientTransactionError) {
            return Center(child: Text(state.message));
          }

          if (state is ReadClientTransactionSuccess || state is FetchingNextPage) {
            final transactions = (state is ReadClientTransactionSuccess)
                ? state.transactions
                : (state as FetchingNextPage).transactions;

            if (transactions.isEmpty) {
              return const Center(child: Text("No se encontraron movimientos registrados en esta sesión de crédito."));
            }

            return Align(
              alignment: Alignment.topCenter,
              child: ListView.separated(
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                shrinkWrap: true,
                itemCount: transactions.length + (state is FetchingNextPage ? 1 : 0),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index >= transactions.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final transaction = transactions[index];
                  final rowColor = index.isOdd ? Colors.grey.shade100 : Colors.white;

                  return MovementMobileRow(
                    currentTransaction: transaction,
                    rowColor: rowColor,
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
