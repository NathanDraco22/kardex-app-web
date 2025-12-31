import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/entry_history/entry_history.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/cubit/write_entry_doc_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/modals/confirmation_save_modal.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/view/mediator.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
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
    final mediator = InventoryEntryMediator.watch(context)!;
    final headerData = mediator.headerData;

    void Function()? onPressed;

    if (mediator.hasMobileAllRequiredFields()) {
      onPressed = () async {
        if (mediator.hasMobileProductWithZeroValue()) {
          DialogManager.showErrorDialog(context, "No se pueden guardar productos con valor 0");
          return;
        }

        final rowCards = mediator.productListViewController.rowCards;

        final confirmationItems = rowCards.map(
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

        final entryDocItems = mediator.productListViewController.rowCards.map((e) {
          return EntryItem(
            productId: e.product.id,
            productName: e.product.name,
            brandName: e.product.brandName,
            unitName: e.product.unitName,
            code: e.product.code,
            quantity: e.quantity,
            cost: e.unitaryCost,
            expirationDate: e.expirationDate?.millisecondsSinceEpoch,
          );
        });

        if (!context.mounted) return;

        final (currentUser, _) = SessionTool.getFullUserFrom(context);

        final createEntryDoct = CreateEntryDoc(
          supplierId: headerData.supplier!.id,
          docNumber: headerData.docNumber!,
          docDate: headerData.docDate!,
          branchId: BranchesTool.getCurrentBranchId(),
          items: entryDocItems.toList(),
          createdBy: UserInfo(
            id: currentUser.id,
            name: currentUser.username,
          ),
        );
        context.read<WriteEntryDocCubit>().createNewEntryDoc(createEntryDoct);
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
