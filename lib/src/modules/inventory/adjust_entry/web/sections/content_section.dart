part of '../../adjust_entry_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = AdjustEntryMediator.read(context)!;
    final tableController = mediator.productTableController;

    return InventoryMovementProductTable(
      controller: tableController,
      haveExpirationDate: false,
      onAddRowAction: (controller) async {
        final res = await showSearchProductInBranchDialog(context, useAverageCost: true);
        if (res == null) return;
        if (controller.rows.length > 99) {
          if (!context.mounted) return;
          await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
          return;
        }
        final productRow = ProductRow(
          product: res,
          quantity: 0,
          unitaryCost: res.account.averageCost,
          editableCost: false,
          haveExpirationDate: false,
        );
        controller.addRow(productRow);
        mediator.refresh();
      },
      onRemoveRowAction: (controller, row) {
        controller.removeRow(row);
      },
      onUpdateRowAction: (controller, row) async {
        final res = await showSearchProductInBranchDialog(context);
        if (res == null) return;
        final newProductRow = ProductRow(
          product: res,
          quantity: 0,
          unitaryCost: res.account.averageCost,
          editableCost: true,
          haveExpirationDate: false,
        );
        controller.updateRow(row, newProductRow);
      },
    );
  }
}
