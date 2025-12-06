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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: SearchFieldDebounced(
                    onSearch: (value) => cubit.searchClientByKeyword(value),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ReadClientCubit, ReadClientState>(
            builder: (context, state) {
              if (state is! ReadClientSearching) return const SizedBox();
              return const LinearProgressIndicator();
            },
          ),

          const SizedBox(height: 12),
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
                    return MobileRow(
                      color: rowColor,
                      title: currentClient.name,
                      isActive: currentClient.isActive,
                      subtitle1: "Saldo: $balanceFormatted",
                      onTab: () {
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
