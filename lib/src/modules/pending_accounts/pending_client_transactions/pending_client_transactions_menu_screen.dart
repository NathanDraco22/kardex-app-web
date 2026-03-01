import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_pending_client_cubit.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/show_client_with_balance_search_dialog.dart';
import 'credit_session_transactions_screen.dart';

class PendingClientTransactionsMenuScreen extends StatelessWidget {
  const PendingClientTransactionsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadPendingClientCubit(context.read<ClientsRepository>())..loadPendingClients(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transacciones con Saldo Pendiente"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Clientes con Saldo Pendiente",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final client = await showClientWithBalanceSearch(context);

                        if (client == null) return;
                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CreditSessionTransactionsScreen(
                                client: client,
                              );
                            },
                          ),
                        );
                      },
                      label: const Text("Buscar Cliente con Saldo"),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: _Content(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: BlocBuilder<ReadPendingClientCubit, ReadPendingClientState>(
        builder: (context, state) {
          if (state is ReadPendingClientLoading || state is ReadPendingClientInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadPendingClientError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ReadPendingClientSuccess;

          if (state.clients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 40, color: Colors.grey),
                  Text("No hay clientes pendientes", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              height: 0.0,
            ),
            itemCount: state.clients.length,
            itemBuilder: (context, index) {
              final currentClient = state.clients[index];
              final balanceFormatted = NumberFormatter.convertToMoneyLike(currentClient.balance);
              final tileColor = index.isOdd ? Colors.grey.shade200 : Colors.white;
              return ListTile(
                tileColor: tileColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CreditSessionTransactionsScreen(
                          client: currentClient,
                        );
                      },
                    ),
                  );
                },
                title: Row(
                  children: [
                    Expanded(child: Text("${currentClient.id} - ${currentClient.name}")),
                    Expanded(
                      child: Text(
                        balanceFormatted,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
