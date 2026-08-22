part of '../../adjust_exit_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustExitMediator.watch(context);
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
                  Row(
                    children: [
                      Flexible(
                        child: TitleTextField(
                          title: "Sucursal",
                          initialValue: currentBranch.name,
                          readOnly: true,
                        ),
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
    final viewController = AdjustExitMediator.watch(context);
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
  final viewController = AdjustExitMediator.read(context);
  if (!viewController.hasAllRequiredFields) return;

  if (viewController.hasProductWithZeroValue) {
    await DialogManager.showErrorDialog(context, "No se pueden guardar productos con cantidad 0");
    return;
  }

  final res = await DialogManager.slideToConfirmActionDialog(
    context,
    "¿Deseas guardar la Salida? (No se puede deshacer)",
  );

  if (res != true) return;

  final createDto = viewController.generateCreateAdjustExit();
  if (createDto == null) return;

  if (!context.mounted) return;
  context.read<WriteAdjustExitCubit>().createAdjustExit(createDto);
}

String getAdjustExitTypeLabel(AdjustExitType type) {
  switch (type) {
    case AdjustExitType.adjust:
      return "Ajuste";
    case AdjustExitType.loss:
      return "Pérdida";
    case AdjustExitType.devolution:
      return "Devolución";
  }
}
