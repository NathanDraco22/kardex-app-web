import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/inventory/create_transfer/mediator.dart';
import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/transfer_item.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

class NewMobileCardNotification extends Notification {
  BuildContext cardContext;
  NewMobileCardNotification(this.cardContext);
}

class MobileProductCard extends StatefulWidget {
  const MobileProductCard({required this.row, super.key});

  final TransferProductRow row;

  @override
  State<MobileProductCard> createState() => MobileProductCardState();
}

class MobileProductCardState extends State<MobileProductCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final FocusNode expirationDateFocusNode = FocusNode();
  final FocusNode quantityFocusNode = FocusNode();

  late final TextEditingController quantityController;
  late final TextEditingController expirationController;

  Color? cardColor;

  CreateTransferNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(
      text: widget.row.quantity > 0 ? widget.row.quantity.toString() : "",
    );
    expirationController = TextEditingController(
      text: widget.row.expirationDate != null ? DateFormat('MM/yy').format(widget.row.expirationDate!) : "",
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NewMobileCardNotification(context).dispatch(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = CreateTransferMediator.read(context)?.notifier;
    if (_notifier != null) {
      _notifier!.registerQuantityFocusNode(widget.row.product.id, quantityFocusNode);
    }
  }

  @override
  void dispose() {
    _notifier?.unregisterCardKey(widget.row.product.id);
    _notifier?.unregisterQuantityFocusNode(widget.row.product.id);
    expirationDateFocusNode.dispose();
    quantityFocusNode.dispose();
    quantityController.dispose();
    expirationController.dispose();
    super.dispose();
  }

  void setCardColorError() {
    setState(() {
      cardColor = Colors.red.shade100;
    });
  }

  void unSetCardColor() {
    setState(() {
      cardColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediator = CreateTransferMediator.read(context)!;

    return Card(
      color: cardColor,
      borderOnForeground: true,
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "Stock: ${widget.row.product.account.availableStock}",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            "Costo: ${NumberFormatter.convertToMoneyLike(widget.row.unitaryCost)}",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
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
                ExpirationDateGate(
                  child: Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Vencimiento"),
                        const SizedBox(
                          height: 6,
                        ),
                        TextField(
                          controller: expirationController,
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
                ),
                const ExpirationDateGate(
                  child: SizedBox(width: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Cantidad"),
                      const SizedBox(
                        height: 6,
                      ),
                      TextField(
                        focusNode: quantityFocusNode,
                        controller: quantityController,
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
                            if (widget.row.quantity > 0) {
                              unSetCardColor();
                            }
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

class SaveButton extends StatelessWidget {
  const SaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    final mediator = CreateTransferMediator.watch(context)!;
    final isDisabled = !mediator.hasAllRequiredFields();

    return IconButton(
      onPressed: isDisabled
          ? null
          : () async {
              if (mediator.hasProductWithZeroValue()) {
                final zeroRow = mediator.productTableController.rows.firstWhere((e) => e.quantity == 0);
                final cardKey = mediator.notifier?.cardKeys[zeroRow.product.id];

                await DialogManager.showErrorDialog(context, "No se pueden guardar productos con cantidad 0");
                if (cardKey?.currentContext != null) {
                  Scrollable.ensureVisible(
                    cardKey!.currentContext!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    alignment: 0.5,
                  );
                  if (cardKey.currentState != null) {
                    cardKey.currentState!.setCardColorError();
                  }
                }
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

              final userWithRole = getIt<AuthCubit>().user;
              if (userWithRole == null) return;

              final originBranch = getIt<AuthCubit>().currentBranch;

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
