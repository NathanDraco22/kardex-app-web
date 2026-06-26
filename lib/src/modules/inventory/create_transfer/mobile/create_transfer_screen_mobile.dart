import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/create_transfer/mediator.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';

import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../web/create_transfer_screen_web.dart';
import 'widgets.dart';

class CreateTransferScreenMobile extends StatelessWidget {
  const CreateTransferScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.read(context)!;
    return BlocListener<WriteTransferCubit, WriteTransferState>(
      listener: (context, state) {
        if (state is WriteTransferLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        } else {
          LoadingDialogManager.closeLoadingDialog(context);
        }

        if (state is WriteTransferSuccess) {
          DialogManager.showInfoDialog(context, "Transferencia ${state.transfer.docNumber} guardada");
          if (!context.mounted) return;
          RebuildTransferScreenNotification().dispatch(context);
        }

        if (state is WriteTransferFailure) {
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final res = await showSearchProductInBranchDelegate(context, true);
              if (res == null) return;
              if (mediator.productTableController.rows.length > 99) {
                if (!context.mounted) return;
                await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
                return;
              }
              final newRow = TransferProductRow(
                product: res,
                quantity: 0,
                unitaryCost: res.account.averageCost,
              );
              mediator.productTableController.addRow(newRow);
              mediator.refresh();
            },
            label: const Text("Agregar Producto"),
            icon: const Icon(Icons.add),
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
          title: const Text(
            "Nueva Transferencia",
          ),
          actions: const [
            SaveButton(),
          ],
        ),
        body: const _MobileBody(),
      ),
    );
  }
}

class _MobileBody extends StatefulWidget {
  const _MobileBody();

  @override
  State<_MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends State<_MobileBody> {
  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.read(context)!;
    return NotificationListener<NewMobileCardNotification>(
      onNotification: (notification) {
        Scrollable.ensureVisible(
          notification.cardContext,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
        return true;
      },
      child: ListView(
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.only(bottom: 112, top: 8),
        children: [
          const _MobileHeaderSection(
            key: ValueKey("header"),
          ),
          const SizedBox(
            height: 12,
          ),
          AnimatedBuilder(
            animation: mediator.productTableController,
            builder: (context, child) {
              return Column(
                children: [
                  for (final row in mediator.productTableController.rows)
                    MobileProductCard(
                      row: row,
                      key: mediator.notifier?.getOrCreateCardKey(row.product.id),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MobileHeaderSection extends StatefulWidget {
  const _MobileHeaderSection({
    super.key,
  });

  @override
  State<_MobileHeaderSection> createState() => _MobileHeaderSectionState();
}

class _MobileHeaderSectionState extends State<_MobileHeaderSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediator = CreateTransferMediator.read(context)!;
    final headerData = mediator.headerData;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Sucursal Origen",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(getIt<AuthCubit>().currentBranchName),
                const SizedBox(height: 12),

                const Text(
                  "Sucursal Destino",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () async {
                    final branches = getIt<AuthCubit>().branches
                        .where((element) => element.id != getIt<AuthCubit>().currentBranchId)
                        .toList();

                    final res = await showBranchSelectionDialog(context, branches);
                    if (res == null) return;
                    headerData.destinationBranch = res;
                    mediator.refresh();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(headerData.destinationBranch?.name ?? "Seleccionar destino"),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                  initialValue: headerData.observations,
                  onChanged: (p0) {
                    headerData.observations = p0;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
