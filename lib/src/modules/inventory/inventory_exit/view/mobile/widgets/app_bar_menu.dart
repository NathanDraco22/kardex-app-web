import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/modals/confirmation_save_modal.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/cubit/write_exit_doc_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/mediator.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class ExitAppBarMenusButton extends StatelessWidget {
  const ExitAppBarMenusButton({super.key});

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
    final mediator = InventoryExitMediator.watch(context)!;
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
        );

        final res = await showConfirmationBottomModal(
          context,
          title: "Guardar Documento?",
          subtitle: "(No se puede deshacer)",
          content: ConfirmationProductListView(
            data: ConfirmationListData(
              items: confirmationItems.toList(),
            ),
          ),
        );

        if (res != true) return;

        final exitDocItems = mediator.productListViewController.rowCards.map((e) {
          return ExitItem(
            productId: e.product.id,
            productName: e.product.name,
            quantity: (e.quantity * -1),
            brandName: e.product.brandName,
            unitName: e.product.unitName,
            code: e.product.code,
          );
        });

        if (!context.mounted) return;

        final (currentUser, _) = SessionTool.getFullUserFrom(context);

        final createExitDoct = CreateExitDoc(
          clientId: headerData.client!.id,
          docNumber: headerData.docNumber!,
          docDate: headerData.docDate!,
          branchId: BranchesTool.getCurrentBranchId(),
          items: exitDocItems.toList(),
          createdBy: UserInfo(
            id: currentUser.id,
            name: currentUser.username,
          ),
        );
        context.read<WriteExitDocCubit>().createNewExitDoc(createExitDoct);
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
