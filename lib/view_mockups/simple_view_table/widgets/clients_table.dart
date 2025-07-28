import 'package:flutter/material.dart';

class ClientsTable extends StatelessWidget {
  const ClientsTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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

          Expanded(
            child: ListView.builder(
              itemCount: 100,

              itemBuilder: (context, index) {
                return Container(
                  color: index.isOdd ? Colors.white : Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Text("Nombre del Producto"),
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
          ),
        ],
      ),
    );
  }
}
