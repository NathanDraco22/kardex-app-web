import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/credit_note_cubit/write_credit_notes_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

Future<CreditNoteInDb?> showCreateCreditNoteDialog(BuildContext context) async {
  final writeCubit = context.read<WriteCreditNoteCubit>();
  final invoiceRepo = context.read<InvoicesRepository>();

  CreditNoteInDb? result;
  final content = BlocProvider.value(
    value: writeCubit,
    child: _CreateCreditNoteDialog(invoicesRepository: invoiceRepo),
  );

  if (context.isMobile()) {
    result = await Navigator.push<CreditNoteInDb?>(
      context,
      MaterialPageRoute(builder: (context) => content),
    );
  } else {
    result = await showDialog<CreditNoteInDb?>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ClipRRect(
          borderRadius: AppThemeTokens.borderRadiusLg,
          child: content,
        ),
      ),
    );
  }

  return result;
}

class _CreateCreditNoteDialog extends StatefulWidget {
  const _CreateCreditNoteDialog({required this.invoicesRepository});

  final InvoicesRepository invoicesRepository;

  @override
  State<_CreateCreditNoteDialog> createState() => _CreateCreditNoteDialogState();
}

class _CreateCreditNoteDialogState extends State<_CreateCreditNoteDialog> {
  CreditNoteType _selectedType = CreditNoteType.devolution;

  // Campos por Factura / Devolución
  final _invoiceSearchController = TextEditingController();
  bool _isSearchingInvoice = false;
  InvoiceInDb? _searchedInvoice;
  final Map<String, int> _returnedQuantities = {}; // product.id -> quantity

  // Campos por Monto
  ClientInDb? _selectedClient;
  final _amountController = TextEditingController();

  // Común
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _invoiceSearchController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _searchInvoice() async {
    final docNumber = _invoiceSearchController.text.trim();
    if (docNumber.isEmpty) return;

    setState(() {
      _isSearchingInvoice = true;
    });

    try {
      final invoice = await widget.invoicesRepository.getInvoiceByDocNumber(docNumber);
      if (!mounted) return;

      setState(() {
        _searchedInvoice = invoice;
        _returnedQuantities.clear();
        for (final item in invoice.saleItems) {
          _returnedQuantities[item.product.id] = 0;
        }
      });
    } catch (e) {
      if (mounted) {
        DialogManager.showErrorDialog(context, "No se encontró la factura \"$docNumber\"");
        setState(() {
          _searchedInvoice = null;
          _returnedQuantities.clear();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingInvoice = false;
        });
      }
    }
  }

  int get _calculatedDevolutionTotal {
    if (_searchedInvoice == null) return 0;
    int total = 0;
    for (final item in _searchedInvoice!.saleItems) {
      final qty = _returnedQuantities[item.product.id] ?? 0;
      total += qty * item.price;
    }
    return total;
  }

  int get _calculatedDevolutionItemsCount {
    if (_searchedInvoice == null) return 0;
    int count = 0;
    for (final qty in _returnedQuantities.values) {
      count += qty;
    }
    return count;
  }

  int get _amountInCents {
    final text = _amountController.text.trim().replaceAll(',', '.');
    final doubleVal = double.tryParse(text) ?? 0.0;
    return (doubleVal * 100).round();
  }

  Future<void> _submit() async {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) {
      DialogManager.showErrorDialog(context, "No hay una sesión activa de usuario");
      return;
    }

    final currentBranch = authState.branch;
    final currentUser = authState.session.user;
    final reason = _reasonController.text.trim();

    if (_selectedType == CreditNoteType.devolution) {
      if (_searchedInvoice == null) {
        DialogManager.showErrorDialog(context, "Debes buscar y seleccionar una factura de origen");
        return;
      }

      final itemsToReturn = <SaleItem>[];
      for (final item in _searchedInvoice!.saleItems) {
        final qty = _returnedQuantities[item.product.id] ?? 0;
        if (qty > 0) {
          itemsToReturn.add(
            SaleItem(
              product: item.product,
              selectedPrice: item.selectedPrice,
              quantity: qty,
              cost: item.cost,
              price: item.price,
              subTotal: qty * item.price,
              total: qty * item.price,
            ),
          );
        }
      }

      if (itemsToReturn.isEmpty) {
        DialogManager.showErrorDialog(context, "Debes seleccionar al menos un producto a devolver con cantidad mayor a 0");
        return;
      }

      final total = _calculatedDevolutionTotal;
      final createDoc = CreateCreditNote(
        branchId: currentBranch.id,
        clientId: _searchedInvoice!.clientId,
        clientInfo: _searchedInvoice!.clientInfo,
        type: CreditNoteType.devolution,
        originalInvoiceId: _searchedInvoice!.id,
        originalInvoiceDocNumber: _searchedInvoice!.docNumber,
        returnedItems: itemsToReturn,
        amount: total,
        description: reason,
        status: CreditNoteStatus.confirmed,
        createdBy: UserInfo(id: currentUser.id, name: currentUser.username),
      );

      final created = await context.read<WriteCreditNoteCubit>().create(createDoc);
      if (created != null && mounted) {
        context.pop(created);
        showCreditNoteViewerDialog(context, created);
      }
    } else {
      // Tipo Monto
      if (_selectedClient == null) {
        DialogManager.showErrorDialog(context, "Debes seleccionar un cliente");
        return;
      }

      final amount = _amountInCents;
      if (amount <= 0) {
        DialogManager.showErrorDialog(context, "El monto debe ser mayor a 0");
        return;
      }

      if (reason.isEmpty) {
        DialogManager.showErrorDialog(context, "El motivo detallado es obligatorio para notas de crédito por monto");
        return;
      }

      final createDoc = CreateCreditNote(
        branchId: currentBranch.id,
        clientId: _selectedClient!.id,
        clientInfo: ClientInfo(
          name: _selectedClient!.name,
          group: _selectedClient!.group,
          phone: _selectedClient!.phone ?? "",
          address: _selectedClient!.address ?? "",
          email: _selectedClient!.email,
          location: _selectedClient!.location,
        ),
        type: CreditNoteType.amount,
        amount: amount,
        description: reason,
        status: CreditNoteStatus.confirmed,
        createdBy: UserInfo(id: currentUser.id, name: currentUser.username),
      );

      final created = await context.read<WriteCreditNoteCubit>().create(createDoc);
      if (created != null && mounted) {
        context.pop(created);
        showCreditNoteViewerDialog(context, created);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDevolution = _selectedType == CreditNoteType.devolution;
    final themeColor = isDevolution ? AppThemeTokens.indigo : AppThemeTokens.teal;

    return BlocListener<WriteCreditNoteCubit, WriteCreditNoteState>(
      listener: (context, state) {
        if (state is WritingCreditNote) {
          LoadingDialogManager.showLoadingDialog(context);
        } else if (state is WriteCreditNoteSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
        } else if (state is WriteCreditNoteError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Encabezado Unificado
              AppDialogHeader(
                title: "Nueva Nota de Crédito",
                subtitle: isDevolution
                    ? "Devolución de mercancía e ingreso al inventario"
                    : "Ajuste directo de saldo / bonificación al cliente",
                icon: isDevolution
                    ? Icons.assignment_return_rounded
                    : Icons.monetization_on_rounded,
                accentColor: themeColor,
                trailingBadge: isDevolution
                    ? AppStatusBadge.indigo(label: "Devolución")
                    : AppStatusBadge.teal(label: "Por Monto"),
                onClose: () => context.pop(),
              ),

              // Contenido con Scroll
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- SELECTOR DE TIPO SEGMENTADO ---
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: AppThemeTokens.borderRadiusMd,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildTypeSegment(
                                    label: "Por Devolución",
                                    icon: Icons.assignment_return_rounded,
                                    isSelected: isDevolution,
                                    accentColor: AppThemeTokens.indigo,
                                    onTap: () => setState(() => _selectedType = CreditNoteType.devolution),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildTypeSegment(
                                    label: "Por Monto",
                                    icon: Icons.attach_money_rounded,
                                    isSelected: !isDevolution,
                                    accentColor: AppThemeTokens.teal,
                                    onTap: () => setState(() => _selectedType = CreditNoteType.amount),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (isDevolution) ...[
                            // --- BÚSQUEDA DE FACTURA ---
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _invoiceSearchController,
                                    decoration: InputDecoration(
                                      labelText: "Número o Folio de Factura",
                                      hintText: "Ej. 000123",
                                      prefixIcon: const Icon(Icons.receipt_long_rounded),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: AppThemeTokens.borderRadiusMd,
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: AppThemeTokens.borderRadiusMd,
                                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: AppThemeTokens.borderRadiusMd,
                                        borderSide: const BorderSide(color: AppThemeTokens.indigo, width: 1.5),
                                      ),
                                      isDense: true,
                                    ),
                                    keyboardType: TextInputType.text,
                                    onSubmitted: (_) => _searchInvoice(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isSearchingInvoice ? null : _searchInvoice,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppThemeTokens.indigo,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppThemeTokens.borderRadiusMd,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    icon: _isSearchingInvoice
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                          )
                                        : const Icon(Icons.search_rounded, size: 20),
                                    label: const Text("Buscar", style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- DETALLES DE FACTURA ENCONTRADA ---
                            if (_searchedInvoice != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.receipt_rounded, size: 20, color: AppThemeTokens.indigo),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Factura #${_searchedInvoice!.docNumber}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        AppStatusBadge.info(
                                          label: DateTimeTool.formatddMMyy(_searchedInvoice!.createdAt),
                                          icon: Icons.calendar_today_rounded,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Cliente: ${_searchedInvoice!.clientInfo.name}",
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Total Facturado: ${NumberFormatter.convertToMoneyLike(_searchedInvoice!.total)}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                "Selecciona las unidades a devolver:",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _searchedInvoice!.saleItems.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                  itemBuilder: (context, index) {
                                    final item = _searchedInvoice!.saleItems[index];
                                    final currentQty = _returnedQuantities[item.product.id] ?? 0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.product.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "Facturados: ${item.quantity} | Precio unitario: ${NumberFormatter.convertToMoneyLike(item.price)}",
                                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius: AppThemeTokens.borderRadiusSm,
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_rounded, size: 18),
                                                  splashRadius: 18,
                                                  onPressed: currentQty > 0
                                                      ? () {
                                                          setState(() {
                                                            _returnedQuantities[item.product.id] = currentQty - 1;
                                                          });
                                                        }
                                                      : null,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  child: Text(
                                                    "$currentQty",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.5,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add_rounded, size: 18),
                                                  splashRadius: 18,
                                                  onPressed: currentQty < item.quantity
                                                      ? () {
                                                          setState(() {
                                                            _returnedQuantities[item.product.id] = currentQty + 1;
                                                          });
                                                        }
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ] else ...[
                            // --- SELECTOR DE CLIENTE (POR MONTO) ---
                            InkWell(
                              onTap: () async {
                                final client = await showClientSelectionDialog(context);
                                if (client != null) {
                                  setState(() => _selectedClient = client);
                                }
                              },
                              borderRadius: AppThemeTokens.borderRadiusMd,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  border: Border.all(
                                    color: _selectedClient != null
                                        ? AppThemeTokens.teal.withValues(alpha: 0.5)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppThemeTokens.teal.withValues(alpha: 0.12),
                                        borderRadius: AppThemeTokens.borderRadiusSm,
                                      ),
                                      child: const Icon(Icons.person_rounded, color: AppThemeTokens.teal),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedClient != null ? _selectedClient!.name : "Seleccionar Cliente",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.5,
                                              color: _selectedClient != null
                                                  ? const Color(0xFF0F172A)
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _selectedClient != null
                                                ? "Saldo actual de deuda: ${NumberFormatter.convertToMoneyLike(_selectedClient!.balance)}"
                                                : "Toca para abrir el catálogo de clientes",
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF94A3B8)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            TextField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*[\,\.]?\d{0,2}')),
                              ],
                              decoration: InputDecoration(
                                labelText: "Monto a Acreditar",
                                hintText: "0.00",
                                prefixIcon: const Icon(Icons.monetization_on_rounded),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: AppThemeTokens.teal, width: 1.5),
                                ),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // --- MOTIVO / DESCRIPCIÓN ---
                          TextField(
                            controller: _reasonController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: isDevolution
                                  ? "Motivo / Observaciones (Opcional)"
                                  : "Motivo Detallado (Obligatorio)*",
                              hintText: "Ej. Mercadería dañada, bonificación por fidelidad...",
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: AppThemeTokens.borderRadiusMd,
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppThemeTokens.borderRadiusMd,
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppThemeTokens.borderRadiusMd,
                                borderSide: BorderSide(color: themeColor, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- RESUMEN DE LA NOTA DE CRÉDITO (BENTO SUMMARY BOX) ---
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.05),
                              borderRadius: AppThemeTokens.borderRadiusLg,
                              border: Border.all(
                                color: themeColor.withValues(alpha: 0.25),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Resumen de la Nota",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: themeColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (isDevolution)
                                      Text(
                                        "$_calculatedDevolutionItemsCount artículo(s)",
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    const Text(
                                      "Total a Acreditar:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      isDevolution
                                          ? NumberFormatter.convertToMoneyLike(_calculatedDevolutionTotal)
                                          : NumberFormatter.convertToMoneyLike(_amountInCents),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        color: themeColor,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- BOTÓN EMITIR ---
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_rounded, size: 20),
                              label: const Text(
                                "Emitir Nota de Crédito",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSegment({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeTokens.borderRadiusSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: AppThemeTokens.borderRadiusSm,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? accentColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
