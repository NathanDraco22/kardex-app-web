part of '../adjust_entry_history_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadAdjustEntryHistoryCubit>();
    return Card(
      key: ValueKey(readCubit.params),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
            children: [
              DatePickerButton(
                defaultDate: DateTime.now().endOfDay(),
                title: "Fecha Limite",
                onSelected: (value) {
                  readCubit.params = readCubit.params.copyWith(endDate: value.endOfDay().millisecondsSinceEpoch);
                  readCubit.loadAdjustEntriesHistory();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final adjustRepo = context.read<AdjustEntriesRepository>();
                      showSimpleSearchDialog<AdjustEntryInDb>(
                        context,
                        title: "Buscar #Documento",
                        searchFuture: (value) {
                          return adjustRepo.getAdjustEntryByDocNumber(value, BranchesTool.getCurrentBranchId());
                        },
                        onResult: (value) {
                          showAdjustEntryViewerDialog(context, value);
                        },
                      );
                    },
                    label: const Text("Buscar #Documento"),
                    icon: const Icon(Icons.search),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      readCubit.setDefaultParams();
                    },
                    label: const Text("Limpiar"),
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
