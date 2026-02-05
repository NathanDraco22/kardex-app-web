part of '../create_transfer_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.read(context)!;
    final tableController = mediator.productTableController;
    return TransferProductTable(
      controller: tableController,
      onAddRowAction: (controller) async {
        final res = await showSearchProductInBranchDialog(context);
        if (res == null) return;

        final currentTotalRow = controller.totalRow;
        if (currentTotalRow > 99) {
          if (!context.mounted) return;
          await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
          return;
        }

        final productRow = TransferProductRow(
          product: res,
          quantity: 0,
          unitaryCost: res.account.averageCost,
        );
        controller.addRow(productRow);
        mediator.refresh();
      },

      onRemoveRowAction: (controller, row) {
        controller.removeRow(row);
        mediator.refresh();
      },
      onUpdateRowAction: (controller, row) async {
        final res = await showSearchProductInBranchDialog(context, product: row.product);
        if (res == null) return;
        final newProductRow = TransferProductRow(
          product: res,
          quantity: 0,
          unitaryCost: 0,
        );
        controller.updateRow(row, newProductRow);
        mediator.refresh();
      },
    );
  }
}
