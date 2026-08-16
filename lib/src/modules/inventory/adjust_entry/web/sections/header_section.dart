part of '../../adjust_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustEntryMediator.watch(context);
    final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;

    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TitleTextField(
                        title: "Sucursal",
                        initialValue: currentBranch.name,
                        readOnly: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            const Text("Fecha Doc"),
                            const SizedBox(height: 6),
                            DateFieldSelector(
                              initDate: viewController.docDate,
                              onSelectedDate: (value) {
                                viewController.docDate = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        Flexible(
          fit: FlexFit.tight,
          child: Card(
            margin: EdgeInsets.zero,
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Flexible(
                      child: Row(
                        children: [
                          Flexible(child: SizedBox.expand()),
                          Flexible(child: MenuActions()),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: FractionallySizedBox(
                              heightFactor: 1.0,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: TitleTextField(
                                  title: "Observaciones",
                                  maxLines: 2,
                                  initialValue: viewController.description,
                                  onChanged: (p0) {
                                    viewController.description = p0;
                                  },
                                ),
                              ),
                            ),
                          ),
                          const Flexible(child: SizedBox.expand()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuActions extends StatelessWidget {
  const MenuActions({super.key});

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustEntryMediator.watch(context);
    final isDisabled = !viewController.hasAllRequiredFields;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedCtrlButton(
          hotKey: "G",
          onPressed: isDisabled ? null : () => saveAction(context),
          icon: Icons.save,
          label: "Guardar",
        ),
      ],
    );
  }
}

Future<void> saveAction(BuildContext context) async {
  final viewController = AdjustEntryMediator.read(context);
  if (!viewController.hasAllRequiredFields) return;

  if (viewController.hasProductWithZeroValue) {
    await DialogManager.showErrorDialog(context, "No se pueden guardar productos con valor 0");
    return;
  }

  final res = await DialogManager.slideToConfirmActionDialog(
    context,
    "¿Deseas guardar el Ajuste? (No se puede deshacer)",
  );

  if (res != true) return;

  final createDto = viewController.generateCreateAdjustEntry();
  if (createDto == null) return;

  if (!context.mounted) return;
  context.read<WriteAdjustEntryCubit>().createAdjustEntry(createDto);
}
