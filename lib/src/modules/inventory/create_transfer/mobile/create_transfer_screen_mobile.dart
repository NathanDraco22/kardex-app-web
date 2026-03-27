import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/transfer_item.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/modules/inventory/create_transfer/mediator.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';

import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../web/create_transfer_screen_web.dart';

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
            onPressed: () async {
              final hasRows = mediator.productTableController.rows.isNotEmpty;
              if (hasRows) {
                final res = await DialogManager.confirmActionDialog(
                  context,
                  "¿Deseas salir sin guardar? (Perderás los cambios)",
                );
                if (res != true) return;
              }
              if (!context.mounted) return;
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
          title: const Text(
            "Nueva Transferencia",
          ),
          actions: const [
            _SaveButton(),
          ],
        ),
        body: const _MobileBody(),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.watch(context)!;
    final isDisabled = !mediator.hasAllRequiredFields();

    return IconButton(
      onPressed: isDisabled
          ? null
          : () async {
              if (mediator.hasProductWithZeroValue()) {
                await DialogManager.showErrorDialog(context, "No se pueden guardar productos con cantidad 0");
                return;
              }

              final res = await DialogManager.slideToConfirmActionDialog(
                context,
                "¿Deseas Guardar la Transferencia? (No se puede deshacer)",
              );

              if (res != true) return;

              if (!context.mounted) return;

              final mediatorRead = CreateTransferMediator.read(context)!;
              final headerData = mediatorRead.headerData;
              final productTableController = mediatorRead.productTableController;

              final items = productTableController.rows.map((e) {
                return TransferItem(
                  id: e.product.id,
                  name: e.product.name,
                  code: e.product.code,
                  unitName: e.product.unitName,
                  brandName: e.product.brandName,
                  quantity: e.quantity,
                  cost: e.unitaryCost,
                  expirationDate: e.expirationDate?.millisecondsSinceEpoch,
                  salePrice: e.product.saleProfile.salePrice,
                  salePrice2: e.product.saleProfile.salePrice2,
                  salePrice3: e.product.saleProfile.salePrice3,
                );
              }).toList();

              final userWithRole = SessionTool.getUserFrom(context);
              if (userWithRole == null) return;

              final originBranch = BranchesTool.getCurrentBranch();

              final createTransfer = CreateTransfer(
                origin: originBranch!.id,
                originName: originBranch.name,
                destination: headerData.destinationBranch!.id,
                destinationName: headerData.destinationBranch!.name,
                status: TransferStatus.inTransit,
                description: headerData.observations ?? "",
                items: items,
                createdBy: UserInfo(
                  id: userWithRole.id,
                  name: userWithRole.username,
                ),
                docNumber: "",
              );

              context.read<WriteTransferCubit>().createTransfer(createTransfer);
            },
      icon: const Icon(Icons.save),
    );
  }
}

class _MobileBody extends StatefulWidget {
  const _MobileBody();

  @override
  State<_MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends State<_MobileBody> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.read(context)!;
    return NotificationListener<NewMobileCardNotification>(
      onNotification: (notification) {
        Future(() {
          scrollController.jumpTo(1.0);
        });
        return true;
      },
      child: ListView(
        addAutomaticKeepAlives: true,
        controller: scrollController,
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
                    _MobileProductCard(row: row, key: ValueKey(row.product.id)),
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
                Text(BranchesTool.getCurrentBranchName()),
                const SizedBox(height: 12),

                const Text(
                  "Sucursal Destino",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () async {
                    final branches = BranchesTool.branches
                        .where((element) => element.id != BranchesTool.getCurrentBranchId())
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

class NewMobileCardNotification extends Notification {}

class _MobileProductCard extends StatefulWidget {
  const _MobileProductCard({required this.row, super.key});

  final TransferProductRow row;

  @override
  State<_MobileProductCard> createState() => _MobileProductCardState();
}

class _MobileProductCardState extends State<_MobileProductCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  FocusNode expirationDateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      expirationDateFocusNode.requestFocus();
      NewMobileCardNotification().dispatch(context);
    });
  }

  @override
  void dispose() {
    expirationDateFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediator = CreateTransferMediator.read(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.row.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.qr_code, size: 12),
                          Text(widget.row.product.displayCode),
                        ],
                      ),
                      Text(
                        "${widget.row.product.brandName} - ${widget.row.product.unitName}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    mediator.productTableController.removeRow(widget.row);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Vencimiento"),
                      const SizedBox(
                        height: 6,
                      ),

                      TextField(
                        autofocus: true,
                        inputFormatters: [MonthYearInputFormatter()],
                        textAlign: TextAlign.start,
                        keyboardType: .number,
                        textInputAction: .next,
                        decoration: const InputDecoration(
                          hintText: "mm/aa",
                          isDense: true,
                        ),
                        onChanged: (value) {
                          try {
                            final date = DateTimeTool.fromMMYY(value);
                            widget.row.expirationDate = date;
                          } on Exception catch (_) {
                            widget.row.expirationDate = null;
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cantidad"),
                      const SizedBox(
                        height: 6,
                      ),
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [IntegerTextInputFormatter()],
                        textAlign: TextAlign.center,
                        textInputAction: .next,
                        decoration: const InputDecoration(
                          isDense: true,
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            widget.row.quantity = 0;
                          } else {
                            widget.row.quantity = int.tryParse(value) ?? 0;
                          }

                          mediator.refresh();
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
    );
  }
}
