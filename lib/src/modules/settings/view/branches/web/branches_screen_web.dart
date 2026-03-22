part of "../branches_screen.dart";

class _BranchesScreenWeb extends StatelessWidget {
  const _BranchesScreenWeb();

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
      appBar: AppBar(
        title: const Text("Ramas/Sucursales"),
      ),
      body: BlocBuilder<ReadBranchCubit, ReadBranchState>(
        builder: (context, state) {
          if (state is ReadBranchLoading || state is ReadBranchInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BranchReadError) {
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
    final cubit = context.watch<ReadBranchCubit>();
    final state = cubit.state as ReadBranchSuccess;
    final branches = state.branches;

    final authCubit = context.watch<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! Authenticated) {
      return const Center(
        child: Text("No autenticado"),
      );
    }

    final user = authState.session.user;
    final isMultiBranch = authState.servin.isMultiBranch;

    return Center(
      child: Padding(
        padding: const EdgeInsetsGeometry.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade600,
                ),
                Text(
                  "Las Ramas/Sucursales no pueden ser eliminadas",
                  style: TextStyle(color: Colors.amber.shade600, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Builder(
              builder: (context) {
                if (!isMultiBranch || user.role != "Admin") {
                  return const SizedBox.shrink();
                }
                if (user.id != "root") {
                  return const SizedBox.shrink();
                }

                return Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final res = await showCreateBranchPriceDialog(context);
                          if (res == null) return;
                          if (!context.mounted) return;
                          await context.read<ReadBranchCubit>().refreshBranch();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Nueva Rama/Sucursal"),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ...List.generate(
                    branches.length,
                    (index) {
                      final branch = branches[index];
                      return ListTile(
                        title: Text(branch.name),
                        subtitle: Text(branch.description),
                        trailing: IconButton(
                          onPressed: () async {
                            final res = await showCreateBranchPriceDialog(
                              context,
                              branch: branch,
                            );
                            if (res == null) return;
                            if (!context.mounted) return;
                            await context.read<ReadBranchCubit>().refreshBranch();
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      );
                    },
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
