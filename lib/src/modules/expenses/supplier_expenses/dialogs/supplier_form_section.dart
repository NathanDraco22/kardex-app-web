part of 'create_supplier_expense_dialog.dart';

class _SupplierFormContent extends StatefulWidget {
  const _SupplierFormContent({
    required this.formKey,
    required this.creationMap,
    this.expense,
  });

  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> creationMap;
  final ExpenseInDb? expense;

  @override
  State<_SupplierFormContent> createState() => _SupplierFormContentState();
}

class _SupplierFormContentState extends State<_SupplierFormContent> {
  static const Color _accent = Color(0xFFEA580C);

  final _supplierFieldKey = GlobalKey<FormFieldState<String>>();
  final _docNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseType selectedType = ExpenseType.supplier;
  int amountInCents = 0;
  int dateTimestamp = DateTime.now().millisecondsSinceEpoch;
  bool isCredit = true;
  int? expirationDateTimestamp;
  String? supplierId;
  String? supplierName;
  int? supplierCreditDays;
  String _category = '';

  ExpenseStatus? _originalStatus;
  late bool _originalIsCredit;
  bool _creditChanged = false;

  bool get _isEditing => widget.expense != null;

  String get _title => _isEditing ? 'Editar Gasto' : 'Nuevo Gasto';

  String get _subtitle => _isEditing
      ? 'Actualiza la información del gasto asociado al proveedor.'
      : 'Registra un pago o compra asociada a un proveedor.';

  @override
  void initState() {
    super.initState();
    widget.creationMap['type'] = selectedType.name;

    final expense = widget.expense;
    if (expense != null) {
      amountInCents = expense.amount;
      dateTimestamp = expense.date;
      isCredit = expense.status != ExpenseStatus.paid;
      expirationDateTimestamp = expense.expirationDate;
      supplierId = expense.supplierId;
      supplierName = expense.supplierName;
      _category = expense.category;
      _docNumberController.text = expense.docNumber;
      _descriptionController.text = expense.description ?? '';
      widget.creationMap['docNumber'] = expense.docNumber;
      widget.creationMap['description'] = expense.description;

      try {
        final suppliersRepo = context.read<SuppliersRepository>();
        final matches = suppliersRepo.suppliers.where((supplier) => supplier.id == supplierId);
        if (matches.isNotEmpty) {
          supplierCreditDays = matches.first.creditDays;
        }
      } catch (_) {
        // El repositorio puede no estar cargado al abrir el formulario.
      }
    }

    widget.creationMap['category'] = _category;
    _originalStatus = expense?.status;
    _originalIsCredit = isCredit;
    _creditChanged = false;
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = _buildFields();
    final submitAction = _submit;

    if (context.isMobile()) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            tooltip: 'Cerrar',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppThemeTokens.borderLight),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: fields,
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildMobileFooter(context, submitAction),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SizedBox(
          width: double.infinity,
          child: Material(
            color: Colors.white,
            borderRadius: AppThemeTokens.borderRadiusXl,
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppDialogHeader(
                  title: _title,
                  subtitle: _subtitle,
                  icon: Icons.storefront_rounded,
                  accentColor: _accent,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: fields,
                  ),
                ),
                _buildDesktopFooter(context, submitAction),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpenseFormSection(
          title: 'Proveedor',
          icon: Icons.business_rounded,
          accentColor: _accent,
          children: [
            InkWell(
              onTap: _selectSupplier,
              borderRadius: AppThemeTokens.borderRadiusMd,
              child: FormField<String>(
                key: _supplierFieldKey,
                initialValue: supplierId,
                validator: (_) {
                  if (supplierId == null || supplierId!.trim().isEmpty) {
                    return 'Debes seleccionar un proveedor';
                  }
                  return null;
                },
                builder: (formFieldState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: AppThemeTokens.borderRadiusMd,
                          border: Border.all(
                            color: formFieldState.hasError ? AppThemeTokens.danger : AppThemeTokens.borderLight,
                            width: formFieldState.hasError ? 1.3 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.10),
                                borderRadius: AppThemeTokens.borderRadiusSm,
                                border: Border.all(color: _accent.withValues(alpha: 0.22)),
                              ),
                              child: const Icon(Icons.business_rounded, color: _accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    supplierName != null && supplierName!.trim().isNotEmpty
                                        ? supplierName!
                                        : 'Seleccionar proveedor',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: supplierName != null && supplierName!.trim().isNotEmpty
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: supplierName != null && supplierName!.trim().isNotEmpty
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    supplierCreditDays == null
                                        ? 'Busca y selecciona un proveedor'
                                        : '$supplierCreditDays días de crédito',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: formFieldState.hasError ? AppThemeTokens.danger : const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                      if (formFieldState.hasError) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            formFieldState.errorText ?? '',
                            style: const TextStyle(color: AppThemeTokens.danger, fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ExpenseFormSection(
          title: 'Información del gasto',
          icon: Icons.receipt_long_rounded,
          accentColor: _accent,
          children: [
            ExpenseFormColumns(
              children: [
                TextFormField(
                  key: const Key('supplier_expense_doc_number_field'),
                  controller: _docNumberController,
                  readOnly: _isEditing,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: expenseFormFieldDecoration(
                    label: 'N° Documento',
                    hint: 'Ej. FACT-2026-00124',
                    accentColor: _accent,
                    prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                    helperText: _isEditing ? 'El número de documento no se puede modificar.' : null,
                    suffixIcon: _isEditing
                        ? const Tooltip(
                            message: 'El número de documento no se puede modificar.',
                            child: Icon(Icons.lock_outline_rounded, size: 18),
                          )
                        : null,
                  ),
                ),
                ExpenseDateField(
                  label: 'Fecha',
                  value: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
                  isRequired: true,
                  accentColor: _accent,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onChanged: (date) {
                    if (date == null) return;
                    setState(() {
                      dateTimestamp = date.millisecondsSinceEpoch;
                      if (isCredit && supplierCreditDays != null) {
                        expirationDateTimestamp = date.add(Duration(days: supplierCreditDays!)).millisecondsSinceEpoch;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExpenseCreditSwitch(
              value: isCredit,
              accentColor: _accent,
              onChanged: (value) {
                setState(() {
                  _creditChanged = value != _originalIsCredit;
                  isCredit = value;
                  if (isCredit && expirationDateTimestamp == null) {
                    final docDate = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
                    expirationDateTimestamp = supplierCreditDays != null
                        ? docDate.add(Duration(days: supplierCreditDays!)).millisecondsSinceEpoch
                        : docDate.millisecondsSinceEpoch;
                  }
                });
              },
            ),
            if (isCredit) ...[
              const SizedBox(height: 12),
              ExpenseDateField(
                label: 'Fecha de Vencimiento',
                value: expirationDateTimestamp == null
                    ? null
                    : DateTime.fromMillisecondsSinceEpoch(expirationDateTimestamp!),
                isRequired: true,
                accentColor: _accent,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                validator: (date) {
                  if (isCredit && date == null) {
                    return 'Selecciona la fecha de vencimiento';
                  }
                  return null;
                },
                onChanged: (date) {
                  if (date == null) return;
                  setState(() {
                    expirationDateTimestamp = date.millisecondsSinceEpoch;
                  });
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ExpenseFormSection(
          title: 'Monto y detalle',
          icon: Icons.payments_rounded,
          accentColor: _accent,
          children: [
            ExpenseAmountField(
              fieldKey: const Key('supplier_expense_amount_field'),
              initialCents: amountInCents,
              accentColor: _accent,
              onCentsChanged: (cents) {
                amountInCents = cents;
                widget.creationMap['amount'] = cents;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 4,
              decoration: expenseFormFieldDecoration(
                label: 'Descripción',
                hint: 'Detalle del pago o compra (opcional)...',
                alignLabelWithHint: true,
                accentColor: _accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter(BuildContext context, VoidCallback submitAction) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppThemeTokens.borderLight)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppThemeTokens.borderRadiusMd,
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryMenuButton(
                onPressed: submitAction,
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                label: const Text(
                  'Guardar',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context, VoidCallback submitAction) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppThemeTokens.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              minimumSize: const Size(44, 44),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          PrimaryMenuButton(
            onPressed: submitAction,
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            label: const Text(
              'Guardar',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectSupplier() async {
    final selected = await showSupplierSelectionDialog(context);
    if (!mounted || selected == null) return;

    _supplierFieldKey.currentState?.didChange(selected.id);
    setState(() {
      supplierId = selected.id;
      supplierName = selected.name;
      supplierCreditDays = selected.creditDays;
      if (isCredit) {
        final docDate = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
        expirationDateTimestamp = docDate.add(Duration(days: selected.creditDays)).millisecondsSinceEpoch;
      }
    });
  }

  void _submit() {
    if (!(widget.formKey.currentState?.validate() ?? false)) return;

    final writeCubit = context.read<WriteExpenseCubit>();
    if (writeCubit.state is WritingExpense) return;

    final authCubit = getIt<AuthCubit>();
    final status = resolveExpenseStatus(
      original: _originalStatus,
      isCredit: isCredit,
      creditChanged: _creditChanged,
    );
    final expirationDate = resolveExpirationDate(
      original: widget.expense?.expirationDate,
      current: expirationDateTimestamp,
      isCredit: isCredit,
      creditChanged: _creditChanged,
    );
    final createdBy = UserInfo(
      id: authCubit.user?.id ?? '',
      name: authCubit.user?.username ?? '',
    );

    widget.creationMap.addAll(
      buildExpensePayload(
        type: selectedType,
        branchId: authCubit.currentBranchId,
        createdBy: createdBy,
        docNumber: _docNumberController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        amount: amountInCents,
        date: dateTimestamp,
        status: status,
        expirationDate: expirationDate,
        supplierId: supplierId ?? '',
        supplierName: supplierName ?? '',
      ),
    );

    if (widget.expense == null) {
      final createExpense = CreateExpense.fromJson(widget.creationMap);
      writeCubit.create(createExpense);
    } else {
      final updateExpense = UpdateExpense.fromJson(widget.creationMap);
      writeCubit.update(widget.expense!.id, updateExpense);
    }
  }
}
