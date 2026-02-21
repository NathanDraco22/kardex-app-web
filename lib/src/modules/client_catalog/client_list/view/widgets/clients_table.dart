import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_list/cubit/client_read_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_list/dialogs/create_client_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/status_tag_label.dart';

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
                  child: Text("Grupo"),
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
    return Ink(
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
              child: Text(client.group),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(client.phone ?? "--"),
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

                child: IconButton(
                  onPressed: () async {
                    final res = await showCreateClientDialog(context, client: client);

                    if (res == null) return;
                    if (!context.mounted) return;
                    await context.read<ReadClientCubit>().markClientUpdated(res);
                    if (!context.mounted) return;
                    context.read<ReadClientCubit>().refreshClient();
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
