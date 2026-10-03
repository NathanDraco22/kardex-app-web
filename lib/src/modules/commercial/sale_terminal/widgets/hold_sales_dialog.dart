import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/core/terminal_draft_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/hold_sale_description_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
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
  String? _selectedUserId;

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

    final lowStockItems = <String>[];
    for (final item in draft.items) {
      final requiredUnits = item.quantity * item.conversionFactor;
      final available = item.product.account.availableStock;
      if (requiredUnits > available) {
        final unitStr = item.selectedUnitName.isNotEmpty ? item.selectedUnitName : 'unid.';
        lowStockItems.add(
          "• ${item.product.name}: requiere ${item.quantity} $unitStr (disponible en inventario: $available)",
        );
      }
    }

    if (lowStockItems.isNotEmpty) {
      if (!mounted) return;
      final proceed = await DialogManager.confirmActionDialog(
        context,
        "Atención: Los siguientes productos tienen menos existencias en inventario de las requeridas:\n\n${lowStockItems.join('\n')}\n\n¿Deseas cargar la venta de todos modos?",
      );
      if (proceed != true) return;
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

    await SaleTerminalDraftManager().updateDescription(draft.id, newDescription);
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

            final (isSeller, sellerUser) = RoleTools.isSeller();
            final allDrafts = drafts;

            // Extraer usuarios únicos que tienen ventas en espera
            final Map<String, String> userMap = {};
            for (final d in allDrafts) {
              if (d.createdBy != null && d.createdBy!.id.isNotEmpty) {
                userMap[d.createdBy!.id] = d.createdBy!.name;
              }
            }

            // Si es vendedor o preventa, restringir forzosamente a su propio usuario
            final effectiveUserId = isSeller ? sellerUser?.id : _selectedUserId;

            // Si el usuario seleccionado ya no tiene ventas, resetear a null (solo si no es vendedor)
            if (!isSeller && _selectedUserId != null && !userMap.containsKey(_selectedUserId)) {
              _selectedUserId = null;
            }

            // Filtrar los drafts por usuario si está seleccionado o si es vendedor/preventa
            final filteredDrafts = effectiveUserId == null
                ? allDrafts
                : allDrafts.where((d) => d.createdBy?.id == effectiveUserId).toList();

            final selectedUserName = effectiveUserId != null
                ? (userMap[effectiveUserId] ?? (isSeller ? sellerUser?.username : null))
                : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isSeller && userMap.isNotEmpty) ...[
                  UserDropdownSelector(
                    selectedUserId: _selectedUserId,
                    selectedUserName: selectedUserName,
                    usersMap: userMap,
                    onIdChanged: (val) {
                      setState(() {
                        _selectedUserId = val;
                      });
                    },
                    onChanged: (user) {
                      setState(() {
                        _selectedUserId = user?.id;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedUserId != null
                          ? "${filteredDrafts.length} de ${allDrafts.length} ventas (${selectedUserName ?? ''})"
                          : "${allDrafts.length} ${allDrafts.length == 1 ? 'venta guardada' : 'ventas guardadas'}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SecondaryMenuButton(
                      onPressed: _clearAll,
                      borderColor: Colors.red.shade200,
                      foregroundColor: Colors.red,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                      label: const Text(
                        "Vaciar todas",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 8),
                Expanded(
                  child: filteredDrafts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_search_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                "No hay ventas de este usuario",
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredDrafts.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final draft = filteredDrafts[index];
                            final hasDescription = draft.description.trim().isNotEmpty;
                            final title = hasDescription
                                ? draft.description.trim()
                                : (draft.client?.name ?? "Consumidor Final");
                            final clientName = draft.client?.name ?? "Consumidor Final";
                            final formattedDate = DateFormat('hh:mm a • dd/MM').format(draft.savedAt);
                            final creatorLabel = draft.createdBy != null && draft.createdBy!.name.isNotEmpty
                                ? " • ${draft.createdBy!.name}"
                                : "";
                            final totalAmount = NumberFormatter.convertToMoneyLike(draft.computedTotalAmount);

                            return Card(
                              margin: EdgeInsets.zero,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.amber.shade300),
                                          ),
                                          child: Icon(
                                            hasDescription ? Icons.bookmark_rounded : Icons.pause_rounded,
                                            color: Colors.amber.shade800,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: Icon(Icons.edit_outlined, color: Colors.blueGrey.shade600, size: 18),
                                          tooltip: "Editar referencia",
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _editDescription(draft),
                                        ),
                                        const SizedBox(width: 2),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                          tooltip: "Descartar",
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => _deleteDraft(draft),
                                        ),
                                        const SizedBox(width: 6),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal.shade600,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () => _loadDraft(draft),
                                          icon: const Icon(Icons.download, size: 14),
                                          label: const Text(
                                            "Cargar",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(height: 1, thickness: 0.8),
                                    const SizedBox(height: 8),
                                    if (hasDescription) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline, size: 13, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
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
                                      const SizedBox(height: 4),
                                    ],
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 6,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.green.shade200),
                                              ),
                                              child: Text(
                                                totalAmount,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              "${draft.computedTotalQuantity} items",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          formattedDate + creatorLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
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
