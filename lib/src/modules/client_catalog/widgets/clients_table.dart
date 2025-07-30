import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cubit/read_client_catalog_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/dialogs/create_client_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/status_tag_label.dart';

class ClientsTable extends StatelessWidget {
  const ClientsTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadClientCatalogCubit>();
    final state = cubit.state as ClientCatalogSuccess;
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
              ],
            ),
          ),
          BlocBuilder<ReadClientCatalogCubit, ClientCatalogState>(
            builder: (context, state) {
              if (state is! ClientCatalogSearching) return const SizedBox();
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
                  child: Text("Cedula"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Telefono"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Center(child: Text("Estado")),
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
    final cubit = context.watch<ReadClientCatalogCubit>();
    final state = cubit.state as ClientCatalogSuccess;
    final clients = state.clients;
    return Expanded(
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final currentClient = clients[index];

          Color color = index.isOdd ? Colors.white : Colors.grey.shade200;

          if (state is HighlightedClient) {
            if (state.updatedClients.any((element) => element.id == currentClient.id)) {
              color = Colors.indigo.shade200;
            } else if (state.newClients.any((element) => element.id == currentClient.id)) {
              color = Colors.yellow.shade200;
            }
          }

          return _RowWidget(
            client: currentClient,
            color: color,
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
    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Text(client.name),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(client.cardId),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(client.phone),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Builder(
                  builder: (context) {
                    if (client.isActive) {
                      return const StatusTagLabel(
                        label: "Activo",
                        isActive: true,
                      );
                    } else {
                      return const StatusTagLabel(
                        label: "Inactivo",
                        isActive: false,
                      );
                    }
                  },
                ),
              ),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.centerRight,

                child: TextButton.icon(
                  onPressed: () async {
                    final res = await showCreateClientDialog(context, client: client);

                    if (res == null) return;
                    if (!context.mounted) return;
                    context.read<ReadClientCatalogCubit>().markClientUpdated(res);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Editar"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
