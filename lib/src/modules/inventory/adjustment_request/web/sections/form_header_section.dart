part of '../adjustment_request_form_web_screen.dart';

class _FormHeaderSection extends StatelessWidget {
  const _FormHeaderSection({required this.editingRequest});

  final AdjustmentRequestInDb? editingRequest;

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustmentRequestMediator.watch(context);
    final authState = getIt<AuthCubit>().state;
    final branchName = authState is Authenticated ? authState.branch.name : '';

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
                        title: 'Sucursal',
                        initialValue: branchName,
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
                            const Text('Fecha Doc'),
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
                    Flexible(
                      child: Row(
                        children: [
                          if (editingRequest != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                'Solicitud ${editingRequest!.docNumber} · ${editingRequest!.items.length} productos',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          const Flexible(child: SizedBox.expand()),
                          Flexible(
                            child: _MenuActions(editingRequest: editingRequest),
                          ),
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
                                  title: 'Observaciones',
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

class _MenuActions extends StatelessWidget {
  const _MenuActions({required this.editingRequest});

  final AdjustmentRequestInDb? editingRequest;

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustmentRequestMediator.watch(context);
    final canSave = viewController.canSave;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedCtrlButton(
          hotKey: 'G',
          onPressed: canSave
              ? () => saveAdjustmentRequestAction(
                    context,
                    editingRequest: editingRequest,
                  )
              : null,
          icon: Icons.save,
          label: 'Guardar',
        ),
      ],
    );
  }
}
