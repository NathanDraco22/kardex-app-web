part of '../history_exit_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    // Cambiado a ReadExitHistoryCubit
    final readCubit = context.read<ReadExitHistoryCubit>();
    return Card(
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Flexible(fit: FlexFit.tight, child: Row()),
            SizedBox(
              height: 70,
              child: Row(
                // crossAxisAlignment y spacing no son propiedades de Row,
                // las he movido a los widgets hijos donde corresponda.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Cliente", // Cambiado de "Proveedor"
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 6),
                        // Cambiado a ClientInDb y ClientsRepository
                        CustomAutocompleteTextfield<ClientInDb>(
                          onClose: (value) => readCubit.clientId = value.id,
                          key: ValueKey(readCubit.clientId),
                          titleBuilder: (value) => value.name,
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
                                    readCubit.clientId = client.id;
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
                  const SizedBox(width: 4), // Espaciado
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 2,
                    child: Row(
                      children: [
                        Flexible(
                          child: DatePickerListTile(
                            key: ValueKey(readCubit.startDate),
                            title: "Fecha Inicio",
                            onSelected: (value) {
                              readCubit.startDate = value.millisecondsSinceEpoch;
                            },
                          ),
                        ),
                        const VerticalDivider(),
                        Flexible(
                          child: DatePickerListTile(
                            key: ValueKey(readCubit.endDate),
                            title: "Fecha Fin",
                            onSelected: (value) {
                              final topEndDate = value.add(
                                const Duration(days: 1),
                              );
                              readCubit.endDate = topEndDate.millisecondsSinceEpoch;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  readCubit.loadPaginatedHistories();
                                },
                                label: const Text("Filtrar"),
                                icon: const Icon(Icons.filter_alt_rounded),
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                onPressed: () {
                                  // Llama al cubit correcto
                                  final readCubit = context.read<ReadExitHistoryCubit>();
                                  readCubit.clearFilterParams();
                                  setState(() {});
                                },
                                child: const Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
