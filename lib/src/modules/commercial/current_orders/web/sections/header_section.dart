part of '../current_orders_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadOrderCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(fit: FlexFit.tight, child: Row()),
            SizedBox(
              height: 70,
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Cliente",
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 6),

                          CustomAutocompleteTextfield<ClientInDb>(
                            key: UniqueKey(),
                            titleBuilder: (value) => value.name,
                            onClose: (value) {
                              readCubit.setFilterParams(clientId: value.id);
                              readCubit.loadPaginatedOrders();
                            },
                            onSearch: (value) async {
                              final repo = context.read<ClientsRepository>();
                              try {
                                final res = await repo.searchClientByKeyword(value);
                                return res;
                              } catch (e) {
                                return [];
                              }
                            },
                            suggestionBuilder: (value, close) {
                              return ListView.builder(
                                itemCount: value.length,
                                itemBuilder: (context, index) {
                                  final client = value[index];
                                  return ListTile(
                                    title: Text(client.name),
                                    onTap: () {
                                      close(client);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {
                readCubit.clearFilterParams();
                setState(() {});
              },
              icon: const Icon(Icons.clear),
              label: const Text("Limpiar"),
            ),
          ],
        ),
      ),
    );
  }
}
