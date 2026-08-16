import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/cubit/write_entry_doc_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/modals/confirmation_save_modal.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/mediator.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class EntryAppBarMenusButton extends StatelessWidget {
  const EntryAppBarMenusButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _SaveButton(),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryEntryMediator.watch(context);

    void Function()? onPressed;

    if (viewController.hasAllRequiredFields) {
      onPressed = () async {
        if (viewController.hasProductWithZeroValue) {
          DialogManager.showErrorDialog(context, "No se pueden guardar productos con valor 0");
          return;
        }

        final rows = viewController.tableController.rows;

        final confirmationItems = rows.map(
          (e) {
            return ConfirmationListItem(
              title: e.product.name,
              quantity: e.quantity,
              unitPrice: e.unitaryCost,
              subtotal: e.subTotal,
            );
          },
        ).toList();

        final res = await showConfirmationBottomModal(
          context,
          title: "Guardar Documento?",
          subtitle: "(No se puede deshacer)",
          content: ConfirmationProductListView(
            data: ConfirmationListData(
              items: confirmationItems,
            ),
          ),
        );

        if (res != true) return;

        final createEntryDoc = viewController.generateCreateEntryDoc();
        if (createEntryDoc == null) return;

        if (!context.mounted) return;
        context.read<WriteEntryDocCubit>().createNewEntryDoc(createEntryDoc);
      };
    }
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      label: const Text("Guardar"),
      icon: const Icon(Icons.save),
    );
  }
}
