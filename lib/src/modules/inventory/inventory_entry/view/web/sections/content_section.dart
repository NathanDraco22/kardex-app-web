part of '../../inventory_entry_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryEntryMediator.read(context)!;
    final tableController = mediator.productTableController;
    return InventoryMovementProductTable(
      controller: tableController,
      onAddRowAction: (controller) async {
        final res = await showSearchProductDialog(context);
        if (res == null) return;
        if (controller.rows.length > 99) {
          if (!context.mounted) return;
          await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
          return;
        }
        if (!context.mounted) return;
        final unit = await showInventoryUnitPicker(context, res);
        if (unit == null) return;
        final productRow = ProductRow(
          product: res,
          quantity: 0,
          unitaryCost: (res is ProductInDbInBranch) ? (res.account.averageCost * unit.conversionFactor) : 0,
          editableCost: true,
          selectedUnitIndex: unit.unitIndex,
          conversionFactor: unit.conversionFactor,
          selectedUnitName: unit.unitName,
        );
        controller.addRow(productRow);
        mediator.refresh();
      },

      onRemoveRowAction: (controller, row) {
        controller.removeRow(row);
      },
      onUpdateRowAction: (controller, row) async {
        final res = await showSearchProductDialog(context, product: row.product);
        if (res == null) return;
        if (!context.mounted) return;
        final unit = await showInventoryUnitPicker(context, res);
        if (unit == null) return;
        final newProductRow = ProductRow(
          product: res,
          quantity: 0,
          unitaryCost: (res is ProductInDbInBranch) ? (res.account.averageCost * unit.conversionFactor) : 0,
          editableCost: true,
          selectedUnitIndex: unit.unitIndex,
          conversionFactor: unit.conversionFactor,
          selectedUnitName: unit.unitName,
        );
        controller.updateRow(row, newProductRow);
      },
    );
  }
}
