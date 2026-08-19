part of '../current_devolutions_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
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
                leading: DevolutionStatusChip(
                  status: currentDevolution.status,
                  width: 100,
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
