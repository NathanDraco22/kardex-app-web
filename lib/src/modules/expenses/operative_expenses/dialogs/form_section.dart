part of 'create_expense_dialog.dart';

class _FormContent extends StatefulWidget {
  const _FormContent({
    required this.formKey,
    required this.creationMap,
    this.expense,
  });

  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> creationMap;
  final ExpenseInDb? expense;

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  static const Color _accent = Color(0xFF16A34A);

  final _docNumberController = TextEditingController();
  final _descriptionController = TextEditingController();

  ExpenseType selectedType = ExpenseType.operative;
  int amountInCents = 0;
  int dateTimestamp = DateTime.now().millisecondsSinceEpoch;
  bool isCredit = false;
  int? expirationDateTimestamp;
  String? category;

  ExpenseStatus? _originalStatus;
  late bool _originalIsCredit;
  bool _creditChanged = false;

  bool get _isEditing => widget.expense != null;

  String get _title => _isEditing ? 'Editar Gasto' : 'Nuevo Gasto';

  String get _subtitle => _isEditing
      ? 'Actualiza la información del gasto operativo.'
      : 'Registra una salida de caja o un gasto operativo.';

  @override
  void initState() {
    super.initState();
    widget.creationMap['type'] = selectedType.name;
    widget.creationMap['supplierId'] = '';

    final expense = widget.expense;
    if (expense != null) {
      amountInCents = expense.amount;
      dateTimestamp = expense.date;
      isCredit = expense.status != ExpenseStatus.paid;
      expirationDateTimestamp = expense.expirationDate;
      category = expense.category.trim().isEmpty ? null : expense.category;
      _docNumberController.text = expense.docNumber;
      _descriptionController.text = expense.description ?? '';
      widget.creationMap['docNumber'] = expense.docNumber;
      widget.creationMap['category'] = expense.category;
      widget.creationMap['description'] = expense.description;
    }

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
                  icon: Icons.account_balance_wallet_rounded,
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
          title: 'Información del gasto',
          icon: Icons.receipt_long_rounded,
          accentColor: _accent,
          children: [
            ExpenseFormColumns(
              children: [
                TextFormField(
                  key: const Key('expense_doc_number_field'),
                  controller: _docNumberController,
                  readOnly: _isEditing,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: expenseFormFieldDecoration(
                    label: 'N° Documento',
                    hint: 'Ej. FAC-2026-00124',
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
                    expirationDateTimestamp = DateTime.now().millisecondsSinceEpoch;
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
          title: 'Clasificación y monto',
          icon: Icons.category_rounded,
          accentColor: _accent,
          children: [
            ExpenseFormColumns(
              children: [
                ExpenseCategoryDropdown(
                  value: category,
                  isRequired: true,
                  label: 'Categoría',
                  decoration: expenseFormFieldDecoration(
                    label: 'Categoría *',
                    accentColor: _accent,
                    suffixIcon: const Icon(Icons.expand_more_rounded, size: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      category = value;
                      widget.creationMap['category'] = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La categoría es requerida';
                    }
                    category = value.trim();
                    widget.creationMap['category'] = value.trim();
                    return null;
                  },
                ),
                ExpenseAmountField(
                  fieldKey: const Key('expense_amount_field'),
                  initialCents: amountInCents,
                  accentColor: _accent,
                  onCentsChanged: (cents) {
                    amountInCents = cents;
                    widget.creationMap['amount'] = cents;
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 4,
              decoration: expenseFormFieldDecoration(
                label: 'Descripción',
                hint: 'Detalle del gasto (opcional)...',
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
        category: category?.trim() ?? '',
        description: _descriptionController.text.trim(),
        amount: amountInCents,
        date: dateTimestamp,
        status: status,
        expirationDate: expirationDate,
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
