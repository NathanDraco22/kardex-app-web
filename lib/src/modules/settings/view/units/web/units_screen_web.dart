part of '../units_screen.dart';

class UnitsScreenWeb extends StatelessWidget {
  const UnitsScreenWeb({super.key});

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
      appBar: AppBar(title: const Text("Unidades")),
      body: BlocBuilder<ReadUnitCubit, ReadUnitState>(
        builder: (context, state) {
          if (state is ReadUnitLoading || state is ReadUnitInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is UnitReadError) {
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
    final cubit = context.watch<ReadUnitCubit>();
    final state = cubit.state as ReadUnitSuccess;
    final units = state.units;

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
                Text(
                  "Las Unidades no pueden ser modificados",
                  style: TextStyle(color: Colors.amber.shade600, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(),

            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateUnitDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadUnitCubit>().refreshUnit();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Unidad de Medida"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ...List.generate(
                    units.length,
                    (index) {
                      final productPrice = units[index];
                      return ListTile(
                        title: Text(productPrice.name),
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
