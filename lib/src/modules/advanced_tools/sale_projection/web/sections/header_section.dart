part of '../sale_projection_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  final int projectionDays;
  final ValueChanged<int> onDaysChanged;

  const _HeaderSection({
    required this.projectionDays,
    required this.onDaysChanged,
  });

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  late BranchInDb currentBranch;
  late TextEditingController _daysController;

  @override
  void initState() {
    super.initState();
    currentBranch = BranchesTool.getCurrentBranch()!;
    _daysController = TextEditingController(text: widget.projectionDays.toString());
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _daysController,
                    decoration: const InputDecoration(
                      labelText: "Días de Proyección",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final days = int.tryParse(value);
                      if (days != null) {
                        widget.onDaysChanged(days);
                      }
                    },
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () async {
                    final cubit = context.read<ReadSaleProjectionCubit>();
                    final state = cubit.state;
                    if (state is! ReadSaleProjectionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No hay datos para exportar")),
                      );
                      return;
                    }

                    try {
                      final days = int.tryParse(_daysController.text);
                      if (days == null) return;
                      final cubit = context.read<ExportExcelCubit>();
                      await cubit.exportExcel(days);
                    } on Exception catch (e) {
                      if (!context.mounted) return;
                      await DialogManager.showErrorDialog(context, e.toString());
                    }
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text("Exportar Excel"),
                ),
                const SizedBox(width: 12),
                _SelectBranchButton(currentBranch: currentBranch),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void setCurrentBranch(BranchInDb branch) {
    setState(() {
      currentBranch = branch;
    });
  }
}

class _SelectBranchButton extends StatelessWidget {
  const _SelectBranchButton({
    required this.currentBranch,
  });

  final BranchInDb currentBranch;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final branches = BranchesTool.branches;
        final selectedBranch = await showBranchSelectionDialog(context, branches);

        if (selectedBranch == null) return;
        if (!context.mounted) return;
        context.findAncestorStateOfType<_HeaderSectionState>()?.setCurrentBranch(selectedBranch);
        context.read<ReadSaleProjectionCubit>().getAllWithAccount(branchId: selectedBranch.id);
      },
      child: Text(
        currentBranch.name,
      ),
    );
  }
}
