part of '../current_devolutions_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final colorsMap = {
      DevolutionStatus.open: Colors.blue.shade400,
      DevolutionStatus.confirmed: Colors.green.shade400,
      DevolutionStatus.cancelled: Colors.red.shade400,
      DevolutionStatus.applied: Colors.grey.shade700,
    };
    final tagMap = {
      DevolutionStatus.open: "Abierta",
      DevolutionStatus.confirmed: "Confirmada",
      DevolutionStatus.cancelled: "Cancelada",
      DevolutionStatus.applied: "Aplicada",
    };
    return Card(
      child: BlocBuilder<ReadDevolutionCubit, ReadDevolutionState>(
        builder: (context, state) {
          if (state is ReadDevolutionLoading || state is ReadDevolutionInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadDevolutionError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ReadDevolutionSuccess;

          final devolutions = state.devolutions;

          return ListView.builder(
            itemCount: devolutions.length,
            itemBuilder: (context, index) {
              final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;
              final currentDevolution = devolutions[index];
              return ListTile(
                tileColor: tileColor,
                onTap: () async {
                  await showDevolutionProcessorDialog(context, currentDevolution);
                },
                leading: Container(
                  width: 100, // Adjusted width for "CONFIRMADA"
                  height: 30,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorsMap[currentDevolution.status],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tagMap[currentDevolution.status] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(currentDevolution.clientInfo.name),
                    const Spacer(),
                    Text(
                      NumberFormatter.convertToMoneyLike(currentDevolution.total),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(
                      DateTimeTool.formatddMMyy(currentDevolution.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "# ${currentDevolution.docNumber}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
