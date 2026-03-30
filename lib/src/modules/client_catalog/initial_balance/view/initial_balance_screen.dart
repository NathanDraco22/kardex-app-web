import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/domain/models/client/initial_balance_model.dart';

import '../cubit/initial_balance_read_cubit.dart';
import '../cubit/initial_balance_write_cubit.dart';
import '../dialogs/set_initial_balance_dialog.dart';

class InitialBalanceScreen extends StatelessWidget {
  const InitialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientRepo = context.read<ClientsRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InitialBalanceReadCubit(clientRepo)..loadClientsWithoutMovements(),
        ),
        BlocProvider(create: (context) => InitialBalanceWriteCubit(clientRepo)),
      ],
      child: const _InitialBalanceView(),
    );
  }
}

class _InitialBalanceView extends StatelessWidget {
  const _InitialBalanceView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<InitialBalanceWriteCubit, InitialBalanceWriteState>(
      listener: (context, state) {
        if (state is InitialBalanceWriteInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        } else if (state is InitialBalanceWriteSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saldo inicial asignado a ${state.client.name} con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          // Remove the client from the list since they now have movements
          context.read<InitialBalanceReadCubit>().removeClientFromList(state.client.id);
        } else if (state is InitialBalanceWriteError) {
          LoadingDialogManager.closeLoadingDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saldos Iniciales Pendientes'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchFieldDebounced(
                onSearch: (value) {
                  context.read<InitialBalanceReadCubit>().searchClientByKeyword(value);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<InitialBalanceReadCubit, InitialBalanceReadState>(
                builder: (context, state) {
                  if (state is InitialBalanceReadLoading || state is InitialBalanceReadInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InitialBalanceReadError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is InitialBalanceReadSuccess) {
                    final clients = state.clients;

                    if (clients.isEmpty) {
                      return const NoItemWidget(
                        text: 'No hay clientes pendientes de saldo inicial.',
                        icon: Icons.check_circle_outline,
                      );
                    }

                    return ListView.separated(
                      itemCount: clients.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(client.name.substring(0, 1).toUpperCase()),
                          ),
                          title: Text(client.name),
                          subtitle: Text(client.cardId ?? "--"),
                          trailing: const Icon(Icons.account_balance_wallet),
                          onTap: () async {
                            final result = await showSetInitialBalanceDialog(context, client);
                            if (result != null) {
                              if (!context.mounted) return;
                              final payload = CreateMultipleInitialBalance(
                                branchId: result.branchId,
                                clientId: client.id,
                                initialBalances: result.balances,
                              );
                              context.read<InitialBalanceWriteCubit>().createMultipleInitialBalance(payload);
                            }
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
