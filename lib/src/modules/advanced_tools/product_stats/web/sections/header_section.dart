part of '../product_stats_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  DateTime? startDate;
  DateTime? endDate;

  late BranchInDb currentBranch;

  @override
  void initState() {
    super.initState();
    currentBranch = BranchesTool.getCurrentBranch()!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EstimateProductStatsCubit, EstimateProductStatsState>(
      listener: (context, state) async {
        if (state is EstimateProductStatsLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        } else {
          LoadingDialogManager.closeLoadingDialog(context);
        }
        if (state is EstimateProductStatsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Estimación completada")),
          );
          context.read<ReadProductStatsCubit>().getAllWithInfo(
            branchId: currentBranch.id,
          );
        }
        if (state is EstimateProductStatsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Card(
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
                  DatePickerButton(
                    title: "Fecha inicial",
                    onSelected: (value) {
                      startDate = value;
                    },
                  ),
                  DatePickerButton(
                    title: "Fecha final",
                    onSelected: (value) {
                      endDate = value.add(const Duration(days: 1));
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (startDate == null || endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Seleccione ambas fechas")),
                        );
                        return;
                      }

                      final confirmed = await showConfirmEstimateDialog(
                        context,
                        startDate: startDate!,
                        endDate: endDate!,
                      );

                      if (confirmed) {
                        if (context.mounted) {
                          final days = endDate!.difference(startDate!).inDays;
                          final startEpoch = startDate!.millisecondsSinceEpoch;
                          final endEpoch = endDate!.millisecondsSinceEpoch;

                          context.read<EstimateProductStatsCubit>().estimate(
                            startDate: startEpoch,
                            endDate: endEpoch,
                            daysAnalysis: days,
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.calculate),
                    label: const Text("Estimar Rotacion"),
                  ),
                ],
              ),
              Row(
                children: [
                  _SelectBranchButton(currentBranch: currentBranch),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setCurrentBranch(BranchInDb branch) {
    currentBranch = branch;
    setState(() {});
  }
}

class _SelectBranchButton extends StatelessWidget {
  const _SelectBranchButton({
    required this.currentBranch,
  });

  final BranchInDb currentBranch;

  @override
  Widget build(BuildContext context) {
    final readStatCubit = context.watch<ReadProductStatsCubit>();
    if (readStatCubit.state is! ReadProductStatsSuccess) {
      return const SizedBox.shrink();
    }
    return TextButton(
      onPressed: () async {
        final branches = BranchesTool.branches;
        final selectedBranch = await showBranchSelectionDialog(context, branches);

        if (selectedBranch == null) return;
        if (!context.mounted) return;
        context.findAncestorStateOfType<_HeaderSectionState>()?.setCurrentBranch(selectedBranch);
        readStatCubit.getAllWithInfo(branchId: selectedBranch.id);
      },
      child: Text(
        currentBranch.name,
      ),
    );
  }
}
