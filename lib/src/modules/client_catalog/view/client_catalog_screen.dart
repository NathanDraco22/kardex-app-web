import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cubit/read_client_catalog_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cubit/write_client_catalog_cubit.dart';

import '../dialogs/create_client_dialog.dart';
import '../widgets/clients_table.dart';

class ClientCatalogScreen extends StatelessWidget {
  const ClientCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientRepo = context.read<ClientsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadClientCatalogCubit(clientRepo)..loadAllClients()),
        BlocProvider(create: (context) => ClientWriteCubit(clientRepo)),
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
      appBar: AppBar(title: const Text("Lista de Clientes")),
      body: BlocBuilder<ReadClientCatalogCubit, ClientCatalogState>(
        builder: (context, state) {
          if (state is ClientCatalogLoading || state is ClientCatalogInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ClientCatalogError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ClientCatalogSuccess;

          return const _Body();
        },
      ),
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
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateClientDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadClientCatalogCubit>().putClientFirst(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Cliente"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: ClientsTable(),
            ),
          ],
        ),
      ),
    );
  }
}
