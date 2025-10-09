part of '../daily_receipt_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadDailyReceiptsCubit>();
    return Card(
      key: ValueKey(readCubit.state),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 70,
              width: 220,
              child: Row(
                children: [
                  Flexible(
                    child: DatePickerListTile(
                      key: ValueKey(readCubit.currentStartDate),
                      defaultDate: readCubit.currentStartDate,
                      title: "Fecha",
                      onSelected: (value) {
                        final currentMidnight = DateTime(
                          value.year,
                          value.month,
                          value.day,
                        );
                        readCubit.currentStartDate = currentMidnight;
                        readCubit.loadDailyReceipts();
                      },
                    ),
                  ),
                  const VerticalDivider(),
                ],
              ),
            ),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomAutocompleteTextfield<ClientInDb>(
                    hintText: "Nombre del cliente",
                    key: ValueKey(readCubit.currentClientId),
                    onClose: (value) {
                      readCubit.currentClientId = value.id;
                      readCubit.loadDailyReceipts();
                    },
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
                              close(client);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        readCubit.clearFilterParams();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.clear,
                      ),
                      label: const Text("Limpiar Filtros"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
