part of '../client_groups_screen.dart';

class ClientGroupsScreenWeb extends StatelessWidget {
  const ClientGroupsScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebScaffold();
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grupos de Clientes")),
      body: BlocBuilder<ReadClientGroupCubit, ReadClientGroupState>(
        builder: (context, state) {
          if (state is ReadClientGroupLoading || state is ReadClientGroupInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ClientGroupReadError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const _WebBody();
        },
      ),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadClientGroupCubit>();
    final state = cubit.state as ReadClientGroupSuccess;
    final groups = state.clientGroups;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  "Los Grupos de Clientes no pueden ser eliminados",
                  style: TextStyle(
                    color: Colors.amber.shade600,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showClientGroupFormDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadClientGroupCubit>().putGroupFirst(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Grupo de Clientes"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: ListView.separated(
                  itemCount: groups.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return ListTile(
                      title: Text(group.name),
                      subtitle: group.description.isNotEmpty ? Text(group.description) : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final res = await showClientGroupFormDialog(context, group: group);
                        if (res == null) return;
                        if (!context.mounted) return;
                        await context.read<ReadClientGroupCubit>().markGroupUpdated(res);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
