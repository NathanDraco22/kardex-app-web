import 'dart:math' as math;

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

import '../credit_note_policy.dart';

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
  // index de línea -> cantidad en unidad comercial (display)
  final Map<int, double> _returnedQuantities = {};
  // index de línea -> cantidad base ya devuelta en notas previas
  final Map<int, int> _previouslyReturnedBase = {};
  int _invoiceSearchGeneration = 0;
  bool _isLoadingPreviousCreditNotes = false;
  String _idempotencyKey = generateCreditNoteIdempotencyKey();

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
        if (_searchedInvoice?.id != invoice.id) {
          _idempotencyKey = generateCreditNoteIdempotencyKey();
        }
        _searchedInvoice = invoice;
        _invoiceSearchGeneration++;
        _previouslyReturnedBase.clear();
        _returnedQuantities.clear();
        for (var index = 0; index < invoice.saleItems.length; index++) {
          _returnedQuantities[index] = 0.0;
        }
      });

      await _loadPreviousCreditNotes(invoice);
    } catch (e) {
      if (mounted) {
        DialogManager.showErrorDialog(context, "No se encontró la factura \"$docNumber\"");
        setState(() {
          _searchedInvoice = null;
          _previouslyReturnedBase.clear();
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

  Future<void> _loadPreviousCreditNotes(InvoiceInDb invoice) async {
    setState(() => _isLoadingPreviousCreditNotes = true);

    try {
      final notes = await context.read<CreditNotesRepository>().getCreditNotesByInvoiceId(invoice.id);

      if (!mounted || _searchedInvoice?.id != invoice.id) return;

      final previous = <int, int>{};
      final legacyItems = <SaleItem>[];

      for (final note in notes) {
        if (note.status == CreditNoteStatus.cancelled) continue;
        for (final item in note.returnedItems) {
          final index = item.invoiceItemIndex;
          if (index != null && index >= 0 && index < invoice.saleItems.length) {
            previous[index] = (previous[index] ?? 0) + item.quantity.abs();
          } else {
            legacyItems.add(item);
          }
        }
      }

      // Fallback para notas antiguas sin invoiceItemIndex: se imputan solo
      // cuando hay una única línea con el mismo producto y conversionFactor.
      for (final item in legacyItems) {
        final matches = <int>[];
        for (var index = 0; index < invoice.saleItems.length; index++) {
          final line = invoice.saleItems[index];
          final sameProduct = line.product.id == item.product.id;
          final sameFactor =
              UnitConversionTool.ensureSafeFactor(line.conversionFactor) ==
              UnitConversionTool.ensureSafeFactor(item.conversionFactor);
          if (sameProduct && sameFactor) matches.add(index);
        }
        if (matches.length == 1) {
          final index = matches.single;
          previous[index] = (previous[index] ?? 0) + item.quantity.abs();
        }
        // Si hay ambigüedad se ignora; el backend sigue validando por índice.
      }

      setState(() {
        _previouslyReturnedBase
          ..clear()
          ..addAll(previous);
        _returnedQuantities.clear();
        for (var index = 0; index < invoice.saleItems.length; index++) {
          _returnedQuantities[index] = 0.0;
        }
        _invoiceSearchGeneration++;
      });
    } catch (_) {
      if (mounted) {
        DialogManager.showErrorDialog(
          context,
          "No se pudieron cargar las devoluciones previas de la factura. "
          "El servidor validará el tope al emitir la nota.",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPreviousCreditNotes = false);
      }
    }
  }

  int _previouslyReturnedFor(int index) => _previouslyReturnedBase[index] ?? 0;

  /// Tope de devolución expresado en unidad comercial, descontando el
  /// acumulado de notas de crédito previas de la misma línea.
  double _maxDisplayQuantity(SaleItem item, int index) {
    final remaining = math.max(0, item.quantity - _previouslyReturnedFor(index));
    return remaining / UnitConversionTool.ensureSafeFactor(item.conversionFactor);
  }

  CreditNoteLineResult _calculateLine(
    SaleItem item,
    int index,
    double displayQuantity,
  ) {
    return calculateCreditNoteLine(
      displayQuantity: displayQuantity,
      conversionFactor: item.conversionFactor,
      invoiceQuantity: item.quantity,
      invoiceSubTotal: item.subTotal,
      invoiceTotal: item.total,
      previouslyReturnedBase: _previouslyReturnedFor(index),
    );
  }

  int get _calculatedDevolutionTotal {
    if (_searchedInvoice == null) return 0;
    final items = _searchedInvoice!.saleItems;
    int total = 0;
    for (var index = 0; index < items.length; index++) {
      final result = _calculateLine(items[index], index, _returnedQuantities[index] ?? 0);
      if (result is CreditNoteLineAmounts) total += result.total;
    }
    return total;
  }

  int get _calculatedDevolutionItemsCount {
    if (_searchedInvoice == null) return 0;
    final items = _searchedInvoice!.saleItems;
    int count = 0;
    for (var index = 0; index < items.length; index++) {
      final result = _calculateLine(items[index], index, _returnedQuantities[index] ?? 0);
      if (result is CreditNoteLineAmounts) count++;
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
      final invoiceItems = _searchedInvoice!.saleItems;
      for (var index = 0; index < invoiceItems.length; index++) {
        final item = invoiceItems[index];
        final displayQuantity = _returnedQuantities[index] ?? 0;
        if (displayQuantity <= 0) continue;

        final result = _calculateLine(item, index, displayQuantity);
        if (result is CreditNoteLineInvalid) {
          DialogManager.showErrorDialog(
            context,
            "${item.product.name}: ${result.message}",
          );
          return;
        }
        if (result is! CreditNoteLineAmounts) continue;

        itemsToReturn.add(
          SaleItem(
            product: item.product,
            selectedPrice: item.selectedPrice,
            quantity: result.quantity,
            bonQuantity: 0,
            cost: item.cost,
            price: item.price,
            subTotal: result.subTotal,
            discountPercentage: item.discountPercentage,
            totalDiscount: result.totalDiscount,
            total: result.total,
            conversionFactor: UnitConversionTool.ensureSafeFactor(item.conversionFactor),
            selectedUnitName: item.selectedUnitName,
            standardUnitName: item.standardUnitName,
            standardUnitFactor: item.standardUnitFactor,
            invoiceItemIndex: index,
          ),
        );
      }

      if (itemsToReturn.isEmpty) {
        DialogManager.showErrorDialog(
          context,
          "Debes seleccionar al menos un producto a devolver con cantidad mayor a 0",
        );
        return;
      }

      final total = itemsToReturn.fold<int>(0, (sum, item) => sum + item.total);
      if (total <= 0) {
        DialogManager.showErrorDialog(
          context,
          "El total de la nota de crédito debe ser mayor a 0",
        );
        return;
      }

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
        idempotencyKey: _idempotencyKey,
      );

      final created = await context.read<WriteCreditNoteCubit>().create(createDoc);
      if (created != null && mounted) {
        context.pop(created);
        showCreditNoteViewerDialog(context, created);
      } else if (mounted) {
        // El backend pudo rechazar el tope acumulado: recargamos lo devuelto.
        await _loadPreviousCreditNotes(_searchedInvoice!);
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
        idempotencyKey: _idempotencyKey,
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
                icon: isDevolution ? Icons.assignment_return_rounded : Icons.monetization_on_rounded,
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
                                    onTap: () => setState(() {
                                      if (_selectedType != CreditNoteType.devolution) {
                                        _idempotencyKey = generateCreditNoteIdempotencyKey();
                                      }
                                      _selectedType = CreditNoteType.devolution;
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: _buildTypeSegment(
                                    label: "Por Monto",
                                    icon: Icons.attach_money_rounded,
                                    isSelected: !isDevolution,
                                    accentColor: AppThemeTokens.teal,
                                    onTap: () => setState(() {
                                      if (_selectedType != CreditNoteType.amount) {
                                        _idempotencyKey = generateCreditNoteIdempotencyKey();
                                      }
                                      _selectedType = CreditNoteType.amount;
                                    }),
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
                                  child: PrimaryMenuButton(
                                    onPressed: _isSearchingInvoice ? null : _searchInvoice,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

                              if (_isLoadingPreviousCreditNotes)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: LinearProgressIndicator(minHeight: 2),
                                ),

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
                                    final currentQty = _returnedQuantities[index] ?? 0.0;
                                    final factor = UnitConversionTool.ensureSafeFactor(
                                      item.conversionFactor,
                                    );
                                    final isBaseUnit = factor <= 1;
                                    final standardFactor = item.standardUnitFactor;
                                    final isSuperiorUnit = standardFactor != null && factor > standardFactor;
                                    final allowsFractions = !isBaseUnit && !isSuperiorUnit;
                                    final previousBase = _previouslyReturnedFor(index);
                                    final maxDisplayQuantity = _maxDisplayQuantity(item, index);
                                    final isFullyReturned = maxDisplayQuantity <= 0;
                                    final displayPrice = item.price * factor;
                                    final details = StringBuffer(
                                      "Facturados: ${item.formattedDisplayQuantity} ${item.displayUnitName}"
                                      " | Precio: ${NumberFormatter.convertToMoneyLike(displayPrice)} / ${item.displayUnitName}",
                                    );
                                    if (previousBase > 0) {
                                      details.write(
                                        " | Devuelto: ${UnitConversionTool.formatQuantity(previousBase / factor)}"
                                        " | Disponible: ${UnitConversionTool.formatQuantity(maxDisplayQuantity)}",
                                      );
                                    }
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
                                                  details.toString(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isFullyReturned
                                                        ? AppThemeTokens.indigo
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 132,
                                            child: QuantityField(
                                              key: ValueKey(
                                                "${_invoiceSearchGeneration}_${_searchedInvoice!.id}_$index",
                                              ),
                                              initialValue: currentQty,
                                              conversionFactor: item.conversionFactor,
                                              allowDecimals: allowsFractions,
                                              step: allowsFractions ? null : 1,
                                              max: maxDisplayQuantity,
                                              equivalenceUnitName: item.standardUnitName ?? item.product.unitName,
                                              equivalenceFactor: item.standardUnitFactor ?? item.conversionFactor,
                                              readOnly: isFullyReturned,
                                              showTitle: false,
                                              showButtons: false,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                filled: true,
                                                fillColor: const Color(0xFFF8FAFC),
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: AppThemeTokens.borderRadiusSm,
                                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: AppThemeTokens.borderRadiusSm,
                                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: AppThemeTokens.borderRadiusSm,
                                                  borderSide: const BorderSide(
                                                    color: AppThemeTokens.indigo,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  _returnedQuantities[index] = value;
                                                });
                                              },
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
                            child: PrimaryMenuButton(
                              onPressed: _submit,
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
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
