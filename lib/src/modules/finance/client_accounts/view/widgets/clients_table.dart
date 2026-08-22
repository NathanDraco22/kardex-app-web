import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/finance/client_movements/view/client_movements_screen.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../../cubit/client_read_cubit.dart';

class ClientsTable extends StatelessWidget {
  const ClientsTable({
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
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  child: SearchFieldDebounced(
                    onSearch: (value) => cubit.searchClientByKeyword(value),
                  ),
                ),
                const Spacer(),
                _WebTotalsSummaryCard(state: state),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Text("Nombre"),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Saldo"),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: SizedBox(),
                ),
              ],
            ),
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

              return const _InnerRows();
            },
          ),
        ],
      ),
    );
  }
}

class _InnerRows extends StatelessWidget {
  const _InnerRows();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadClientCubit>();
    final state = cubit.state as ReadClientSuccess;
    final clients = state.clients;
    return Expanded(
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final currentClient = clients[index];

          Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

          if (state is HighlightedClient) {
            if (state.updatedClients.any((element) => element.id == currentClient.id)) {
              rowColor = Colors.blue.shade100;
            } else if (state.newClients.any((element) => element.id == currentClient.id)) {
              rowColor = Colors.yellow.shade200;
            }
          }

          return _RowWidget(
            client: currentClient,
            color: rowColor,
          );
        },
      ),
    );
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({required this.client, required this.color});

  final ClientInDb client;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final balanceFormatted = NumberFormatter.convertToMoneyLike(client.balance);

    return CustomClientListTile(
      client: client,
      backgroundColor: color,
      trailing: Text(balanceFormatted),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ClientMovementsScreen(initialClient: client);
            },
          ),
        );
      },
    );
  }
}

class _WebTotalsSummaryCard extends StatelessWidget {
  final ReadClientSuccess state;

  const _WebTotalsSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBalanceFormatted = NumberFormatter.convertToMoneyLike(state.totalBalance);
    final filteredBalanceFormatted = NumberFormatter.convertToMoneyLike(state.filteredBalance);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isSearchActive) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Total Filtrado",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  filteredBalanceFormatted,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Text(
                  "${state.clients.length} coincidencias",
                  style: const TextStyle(fontSize: 10.5, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              height: 36,
              width: 1,
              color: Colors.black12,
            ),
            const SizedBox(width: 16),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Total Cartera por Cobrar",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(
                totalBalanceFormatted,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.totalBalance > 0 ? theme.colorScheme.primary : Colors.grey.shade700,
                ),
              ),
              Text(
                "${state.totalDebtorsCount} clientes con saldo pendiente",
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
