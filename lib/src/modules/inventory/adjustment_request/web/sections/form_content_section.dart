part of '../adjustment_request_form_web_screen.dart';

class _FormContentSection extends StatelessWidget {
  const _FormContentSection();

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustmentRequestMediator.watch(context);

    return AdjustmentRequestEditorTable(
      viewController: viewController,
      onAddProduct: () => addAdjustmentRequestProductAction(context),
    );
  }
}
