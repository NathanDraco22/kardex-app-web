import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class ProductCatalogScreen extends StatelessWidget {
  const ProductCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catalogo de Productos")),
      body: const _Body(),
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Agregar Nuevo Producto"),
                            actions: [
                              OutlinedButton(
                                onPressed: () {},
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                child: const Text("Agregar Producto"),
                              ),
                            ],
                            content: const SizedBox(
                              width: 400,
                              height: 500,
                              child: Column(
                                children: [
                                  TitleTextField(
                                    title: "Nombre del Producto",
                                  ),
                                  SizedBox(height: 12),
                                  Placeholder(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Producto"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Card(
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
                            child: Text("Nombre del Producto"),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text("Codigo"),
                          ),

                          Flexible(
                            fit: FlexFit.tight,
                            child: Text("Marca"),
                          ),

                          Flexible(
                            fit: FlexFit.tight,
                            child: Text("Categoria"),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text("Precio de Venta"),
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
                                  const Flexible(
                                    fit: FlexFit.tight,
                                    child: Text("Categoria"),
                                  ),
                                  const Flexible(
                                    fit: FlexFit.tight,
                                    child: Text("Precio de Venta"),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
