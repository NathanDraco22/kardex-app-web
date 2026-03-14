import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/pending_invoice/cubit/read_pending_client_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/unpaid_client_stats_dialog.dart';

class UnpaidClientsScreen extends StatelessWidget {
  const UnpaidClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientRepo = context.read<ClientsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadPendingClientCubit(
            clientRepo,
          )..loadPendingClients(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Días de Impago"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Clientes con Atraso de Pago",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
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
                  Icon(Icons.check_circle_outline, size: 50, color: Colors.green),
                  SizedBox(height: 16),
                  Text("No hay clientes con saldos pendientes.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final now = DateTime.now().startOfDay();
          const int redAlertDays = 37;
          const int yellowAlertDays = 30;

          final clientsWithDays = state.clients.map((client) {
            final baseDate = client.lastReceiptDate ?? client.lastCreditStart;
            final diasImpago = baseDate != null ? now.difference(baseDate.startOfDay()).inDays : 0;
            return (client: client, unpaidDays: diasImpago);
          }).toList();

          clientsWithDays.sort((a, b) => b.unpaidDays.compareTo(a.unpaidDays));

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              height: 0.0,
            ),
            itemCount: clientsWithDays.length,
            itemBuilder: (context, index) {
              final item = clientsWithDays[index];
              final currentClient = item.client;
              final diasImpago = item.unpaidDays;

              final balanceFormatted = NumberFormatter.convertToMoneyLike(currentClient.balance);

              Color? tileColor;
              bool isPastCutoff = false;

              if (currentClient.lastCreditStart != null && currentClient.lastReceiptDate != null) {
                final nextMonth = DateTime(
                  currentClient.lastReceiptDate!.year,
                  currentClient.lastReceiptDate!.month + 1,
                  currentClient.lastCreditStart!.day,
                );
                isPastCutoff = now.isAfter(nextMonth);
              }

              if (diasImpago > redAlertDays) {
                tileColor = Colors.red.shade300;
              } else if (diasImpago > yellowAlertDays || isPastCutoff) {
                tileColor = Colors.amber.shade200;
              } else {
                tileColor = index.isOdd ? Colors.grey.shade50 : Colors.white;
              }

              final lastAbonoStr = currentClient.lastReceiptDate != null
                  ? DateTimeTool.formatddMMyy(currentClient.lastReceiptDate!)
                  : "Ninguno";

              final creditStartDay = currentClient.lastCreditStart?.day.toString() ?? "-";

              return ListTile(
                tileColor: tileColor,
                onTap: () {
                  showUnpaidClientStatsDialog(context, client: currentClient);
                },
                minLeadingWidth: 60,
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$diasImpago",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const Text("Días", style: TextStyle(fontSize: 10)),
                  ],
                ),
                title: Text(
                  "${currentClient.id} - ${currentClient.name}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text("Día de corte: $creditStartDay | Último abono: $lastAbonoStr"),
                trailing: Text(
                  balanceFormatted,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
