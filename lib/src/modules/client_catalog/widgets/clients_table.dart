import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cubit/client_catalog_cubit.dart';
import 'package:kardex_app_front/widgets/no_item.dart';

class ClientsTable extends StatelessWidget {
  const ClientsTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClientCatalogCubit>();
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
                  child: SearchAnchor(
                    builder: (context, controller) {
                      return TextField(
                        onSubmitted: (value) => controller.openView(),
                      );
                    },
                    suggestionsBuilder: (context, controller) {
                      return [Container()];
                    },
                  ),
                ),
              ],
            ),
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
                  child: Text("Telefono"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Email"),
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
    final cubit = context.read<ClientCatalogCubit>();
    final state = cubit.state as ClientCatalogSuccess;
    final clients = state.clients;
    return Expanded(
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final currentClient = clients[index];
          return Container(
            color: index.isOdd ? Colors.white : Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: Text(currentClient.name),
                  ),
                  const Flexible(
                    fit: FlexFit.tight,
                    child: Text("Codigo"),
                  ),
                  const Flexible(
                    fit: FlexFit.tight,
                    child: Text("Marca"),
                  ),

                  Flexible(
                    fit: FlexFit.tight,
                    child: Align(
                      alignment: Alignment.centerRight,

                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text("Editar"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
