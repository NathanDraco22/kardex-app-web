import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class EntryInventoryScreen extends StatelessWidget {
  const EntryInventoryScreen({super.key});

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
      appBar: AppBar(
        title: const Text("New Inventory Entry"),
        actions: [
          MaterialButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        SearchAnchor(
                          builder: (context, controller) {
                            return SearchBar(
                              onChanged: (value) {
                                controller.openView();
                              },
                              controller: controller,
                            );
                          },
                          suggestionsBuilder: (context, controller) {
                            return [Container()];
                          },
                        ),
                        const Spacer(
                          flex: 3,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                Text(
                  "Guardar",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  spacing: 8,
                  children: [
                    Flexible(
                      child: TitleTextField(
                        title: "Proveedor",
                      ),
                    ),

                    Flexible(
                      child: TitleTextField(
                        title: "Numero de Documento",
                        titleTextAlign: TextAlign.center,
                      ),
                    ),
                    Spacer(),
                    Flexible(
                      child: TitleTextField(
                        title: "Fecha",
                        titleTextAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 2,
                              child: Text(
                                "Productos",
                              ),
                            ),

                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                "Marca",
                                textAlign: TextAlign.center,
                              ),
                            ),

                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                "Cantidad",
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(width: 12),

                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                "Costo Unitario",
                                textAlign: TextAlign.center,
                              ),
                            ),

                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                "Subtotal",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 8,
                      ),
                      Flexible(
                        child: ListView.builder(
                          itemCount: 100,
                          itemBuilder: (context, index) {
                            return CustomKardexRow(
                              index: index,
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Flexible(fit: FlexFit.tight, flex: 4, child: SizedBox()),

                            SizedBox(width: 12),

                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                "Total",
                                textAlign: TextAlign.center,
                              ),
                            ),

                            Flexible(
                              fit: FlexFit.tight,
                              child: Text(
                                "999,9999,9999.99",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomKardexRow extends StatelessWidget {
  const CustomKardexRow({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: index.isOdd ? Colors.white : Colors.grey.shade200,
      ),
      child: const Row(
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 2,
            child: TextField(),
          ),

          Flexible(
            fit: FlexFit.tight,
            child: Text(
              "PISA",
              textAlign: TextAlign.center,
            ),
          ),

          Flexible(
            fit: FlexFit.tight,
            child: TextField(),
          ),

          SizedBox(width: 12),

          Flexible(
            fit: FlexFit.tight,
            child: TextField(),
          ),

          Flexible(
            fit: FlexFit.tight,
            child: Text(
              "9,999,999.99",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
