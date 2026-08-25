import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/core/terminal_draft_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/hold_sale_description_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> showHoldSalesDialog(
  BuildContext context, {
  required String branchId,
  required SaleTerminalViewController viewController,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _HoldSalesDialogContent(
        branchId: branchId,
        viewController: viewController,
      );
    },
  );
}

class _HoldSalesDialogContent extends StatefulWidget {
  const _HoldSalesDialogContent({
    required this.branchId,
    required this.viewController,
  });

  final String branchId;
  final SaleTerminalViewController viewController;

  @override
  State<_HoldSalesDialogContent> createState() => _HoldSalesDialogContentState();
}

class _HoldSalesDialogContentState extends State<_HoldSalesDialogContent> {
  late Future<List<SaleTerminalDraft>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _reloadDrafts();
  }

  void _reloadDrafts() {
    _draftsFuture = SaleTerminalDraftManager().getDrafts(widget.branchId);
  }

  Future<void> _loadDraft(SaleTerminalDraft draft) async {
    if (widget.viewController.items.isNotEmpty) {
      final confirm = await DialogManager.confirmActionDialog(
        context,
        "Tienes productos en la venta actual.\n¿Deseas reemplazarla por esta venta en espera?",
      );
      if (confirm != true) return;
    }

    widget.viewController.loadFromDraft(draft);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _deleteDraft(SaleTerminalDraft draft) async {
    final confirm = await DialogManager.confirmActionDialog(
      context,
      "¿Deseas descartar esta venta en espera?",
    );
    if (confirm != true) return;

    await SaleTerminalDraftManager().removeDraft(widget.branchId, draft.id);
    if (!mounted) return;
    setState(() {
      _reloadDrafts();
    });
  }

  Future<void> _editDescription(SaleTerminalDraft draft) async {
    final newDescription = await showHoldSaleDescriptionDialog(
      context,
      initialValue: draft.description,
      clientName: draft.client?.name,
      isEditing: true,
    );

    if (newDescription == null || newDescription == draft.description) return;

    final updatedDraft = SaleTerminalDraft(
      id: draft.id,
      savedAt: draft.savedAt,
      client: draft.client,
      selectedPriceLevel: draft.selectedPriceLevel,
      isWholesale: draft.isWholesale,
      description: newDescription,
      selectedPaymentType: draft.selectedPaymentType,
      items: draft.items,
    );

    await SaleTerminalDraftManager().saveDraft(widget.branchId, updatedDraft);
    if (!mounted) return;
    setState(() {
      _reloadDrafts();
    });
  }

  Future<void> _clearAll() async {
    final confirm = await DialogManager.confirmActionDialog(
      context,
      "¿Deseas eliminar TODAS las ventas en espera?",
    );
    if (confirm != true) return;

    await SaleTerminalDraftManager().clearAllDrafts(widget.branchId);
    if (!mounted) return;
    setState(() {
      _reloadDrafts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      title: Row(
        children: [
          Icon(Icons.pause_circle_outline, color: Colors.amber.shade800, size: 26),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Ventas en Espera",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: "Cerrar",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        height: 440,
        child: FutureBuilder<List<SaleTerminalDraft>>(
          future: _draftsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final drafts = snapshot.data ?? [];
            if (drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pause_circle_outline, size: 54, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      "No hay ventas en espera",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Usa 'Poner en espera' en el carrito para guardar ventas temporales.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${drafts.length} ${drafts.length == 1 ? 'venta guardada' : 'ventas guardadas'}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: Colors.red),
                      label: const Text(
                        "Vaciar todas",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: drafts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final draft = drafts[index];
                      final hasDescription = draft.description.trim().isNotEmpty;
                      final title = hasDescription ? draft.description.trim() : (draft.client?.name ?? "Consumidor Final");
                      final clientName = draft.client?.name ?? "Consumidor Final";
                      final formattedDate = DateFormat('hh:mm a • dd/MM').format(draft.savedAt);
                      final totalAmount = NumberFormatter.convertToMoneyLike(draft.totalAmount);

                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.amber.shade300),
                                ),
                                child: Icon(
                                  hasDescription ? Icons.bookmark_rounded : Icons.pause_rounded,
                                  color: Colors.amber.shade800,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (hasDescription) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline, size: 13, color: Colors.grey.shade600),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              clientName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    Row(
                                      children: [
                                        Text(
                                          "${draft.totalQuantity} items • $totalAmount",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "• $formattedDate",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: Colors.blueGrey.shade600, size: 20),
                                tooltip: "Editar referencia",
                                onPressed: () => _editDescription(draft),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                tooltip: "Descartar",
                                onPressed: () => _deleteDraft(draft),
                              ),
                              const SizedBox(width: 4),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _loadDraft(draft),
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text("Cargar", style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
