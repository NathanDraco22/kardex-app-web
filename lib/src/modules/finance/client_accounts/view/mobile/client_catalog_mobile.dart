part of '../client_account_screen.dart';

class ClientAccountMobile extends StatelessWidget {
  const ClientAccountMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de cuenta de Clientes"),
      ),
      body: BlocBuilder<ReadClientCubit, ReadClientState>(
        builder: (context, state) {
          if (state is ReadClientLoading || state is ReadClientInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ClientReadError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const _MobileBody();
        },
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            SizedBox(height: 12),

            Expanded(
              child: MobileClientsTable(),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileClientsTable extends StatelessWidget {
  const MobileClientsTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadClientCubit>();
    final state = cubit.state as ReadClientSuccess;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: SearchFieldDebounced(
              onSearch: (value) => cubit.searchClientByKeyword(value),
            ),
          ),
          BlocBuilder<ReadClientCubit, ReadClientState>(
            builder: (context, state) {
              if (state is! ReadClientSearching) return const SizedBox();
              return const LinearProgressIndicator();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _MobileTotalsCard(state: state),
          ),
          const Divider(),

          Builder(
            builder: (context) {
              if (state.clients.isEmpty) {
                return const Center(
                  child: NoItemWidget(
                    icon: Icons.perm_contact_calendar_outlined,
                    text: "No hay clientes",
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: state.clients.length,
                  itemBuilder: (BuildContext context, int index) {
                    final currentClient = state.clients[index];

                    Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

                    if (state is HighlightedClient) {
                      if (state.updatedClients.any((element) => element.id == currentClient.id)) {
                        rowColor = Colors.blue.shade100;
                      } else if (state.newClients.any((element) => element.id == currentClient.id)) {
                        rowColor = Colors.yellow.shade200;
                      }
                    }

                    final balanceFormatted = NumberFormatter.convertToMoneyLike(currentClient.balance);
                    return CustomClientListTile(
                      client: currentClient,
                      backgroundColor: rowColor,
                      trailing: Text(balanceFormatted),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ClientMovementsScreen(initialClient: currentClient);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MobileTotalsCard extends StatelessWidget {
  final ReadClientSuccess state;

  const _MobileTotalsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBalanceFormatted = NumberFormatter.convertToMoneyLike(state.totalBalance);
    final filteredBalanceFormatted = NumberFormatter.convertToMoneyLike(state.filteredBalance);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Total Cartera por Cobrar",
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  totalBalanceFormatted,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  "${state.totalDebtorsCount} clientes con saldo pendiente",
                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ),
          if (state.isSearchActive) ...[
            Container(
              height: 32,
              width: 1,
              color: Colors.black12,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Filtrado",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  filteredBalanceFormatted,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Text(
                  "${state.clients.length} result.",
                  style: const TextStyle(fontSize: 9.5, color: Colors.black45),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
