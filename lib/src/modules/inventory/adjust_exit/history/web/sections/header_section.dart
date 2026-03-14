part of '../adjust_exit_history_web_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadAdjustExitHistoryCubit>();
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
                  readCubit.loadAdjustExitsHistory();
                },
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final adjustRepo = context.read<AdjustExitsRepository>();
                      showSimpleSearchDialog<AdjustExitInDb>(
                        context,
                        title: "Buscar #Documento",
                        searchFuture: (value) {
                          // Search by Doc Number
                          return adjustRepo.getAdjustExitByDocNumber(value, BranchesTool.getCurrentBranchId());
                        },
                        onResult: (value) {
                          showAdjustExitViewerDialog(context, value);
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
