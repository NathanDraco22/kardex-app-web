part of '../history_entry_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadEntryHistoryCubit>();
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
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Proveedor",
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 6),
                        CustomAutocompleteTextfield<SupplierInDb>(
                          onClose: (value) => readCubit.supplierId = value.id,
                          key: ValueKey(readCubit.supplierId),
                          titleBuilder: (value) => value.name,
                          onSearch: (value) async {
                            final repo = context.read<SuppliersRepository>();
                            try {
                              final res = await repo.searchSupplierByKeyword(value);
                              return res;
                            } catch (e) {
                              return [];
                            }
                          },
                          suggestionBuilder: (value, close) {
                            return ListView.builder(
                              itemCount: value.length,
                              itemBuilder: (context, index) {
                                final supplier = value[index];
                                return ListTile(
                                  title: Text(supplier.name),
                                  onTap: () {
                                    readCubit.supplierId = supplier.id;
                                    close(supplier);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

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
                              final endTopDate = value.add(const Duration(days: 1));
                              readCubit.endDate = endTopDate.millisecondsSinceEpoch;
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
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
                                icon: const Icon(
                                  Icons.filter_alt_rounded,
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              FilledButton(
                                onPressed: () {
                                  final readCubit = context.read<ReadEntryHistoryCubit>();
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
