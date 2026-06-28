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
  final _supplierFieldKey = GlobalKey<FormFieldState<String>>();
  ExpenseType selectedType = ExpenseType.supplier;
  int amountInCents = 0;
  int dateTimestamp = DateTime.now().millisecondsSinceEpoch;
  bool isCredit = true; // Crédito por defecto
  int? expirationDateTimestamp;
  String? supplierId;
  String? supplierName;
  int? supplierCreditDays;

  @override
  void initState() {
    super.initState();
    widget.creationMap['type'] = selectedType.name;
    widget.creationMap['category'] = ""; // La categoría no es requerida aquí
    if (widget.expense != null) {
      amountInCents = widget.expense!.amount;
      dateTimestamp = widget.expense!.date;
      isCredit = widget.expense!.status != ExpenseStatus.paid;
      expirationDateTimestamp = widget.expense!.expirationDate;
      supplierId = widget.expense!.supplierId;
      supplierName = widget.expense!.supplierName;
      widget.creationMap['docNumber'] = widget.expense!.docNumber;
      widget.creationMap['description'] = widget.expense!.description;

      try {
        final suppliersRepo = context.read<SuppliersRepository>();
        final matches = suppliersRepo.suppliers.where((s) => s.id == supplierId);
        if (matches.isNotEmpty) {
          supplierCreditDays = matches.first.creditDays;
        }
      } catch (_) {
        // En caso de que no esté cargado el repositorio o falle la lectura
      }
    } else {
      isCredit = true; // Crédito por defecto al crear
    }
  }

  Future<void> _selectSupplier() async {
    final selected = await showSupplierSelectionDialog(context);
    if (selected != null) {
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
  }

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<WriteExpenseCubit>();
    final wordPrefix = widget.expense == null ? "Crear" : "Actualizar";

    widget.creationMap['supplierId'] = supplierId ?? "";
    widget.creationMap['supplierName'] = supplierName ?? "";
    widget.creationMap['amount'] = amountInCents;
    widget.creationMap['date'] = dateTimestamp;

    final fields = [
      // Fila de selección de proveedor
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Proveedor*",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _selectSupplier,
            borderRadius: BorderRadius.circular(8),
            child: FormField<String>(
              key: _supplierFieldKey,
              initialValue: supplierId,
              validator: (_) {
                if (supplierId == null || supplierId!.isEmpty) {
                  return "Debes seleccionar un proveedor";
                }
                return null;
              },
              builder: (formFieldState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: formFieldState.hasError ? Colors.red : Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.business,
                            color: formFieldState.hasError ? Colors.red : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              supplierName != null && supplierName!.isNotEmpty
                                  ? supplierName!
                                  : "Presiona para seleccionar un proveedor",
                              style: TextStyle(
                                fontSize: 16,
                                color: supplierName != null && supplierName!.isNotEmpty
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                                fontWeight: supplierName != null && supplierName!.isNotEmpty
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: formFieldState.hasError ? Colors.red : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    if (formFieldState.hasError) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          formFieldState.errorText ?? "",
                          style: const TextStyle(color: Colors.red, fontSize: 12),
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
      Row(
        children: [
          Flexible(
            child: TitleTextField(
              title: "N° Documento",
              initialValue: widget.expense?.docNumber,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              validator: (value) {
                widget.creationMap['docNumber'] = value?.trim() ?? "";
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: DatePickerButton(
              title: "Fecha*",
              defaultDate: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
              onSelected: (selectedDate) {
                setState(() {
                  dateTimestamp = selectedDate.millisecondsSinceEpoch;
                  if (isCredit && supplierCreditDays != null) {
                    expirationDateTimestamp = selectedDate
                        .add(Duration(days: supplierCreditDays!))
                        .millisecondsSinceEpoch;
                  }
                });
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                setState(() {
                  isCredit = !isCredit;
                  if (isCredit) {
                    final docDate = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
                    expirationDateTimestamp = supplierCreditDays != null
                        ? docDate.add(Duration(days: supplierCreditDays!)).millisecondsSinceEpoch
                        : (expirationDateTimestamp ?? docDate.millisecondsSinceEpoch);
                  }
                });
              },
              child: SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("¿Crédito?"),
                    Switch(
                      value: isCredit,
                      onChanged: (value) {
                        setState(() {
                          isCredit = value;
                          if (isCredit) {
                            final docDate = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
                            expirationDateTimestamp = supplierCreditDays != null
                                ? docDate.add(Duration(days: supplierCreditDays!)).millisecondsSinceEpoch
                                : (expirationDateTimestamp ?? docDate.millisecondsSinceEpoch);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isCredit) ...[
            const SizedBox(width: 12),
            Flexible(
              child: DatePickerButton(
                title: "Fecha de Vencimiento*",
                defaultDate: DateTime.fromMillisecondsSinceEpoch(
                  expirationDateTimestamp ?? DateTime.now().millisecondsSinceEpoch,
                ),
                maxDateTime: DateTime.now().add(const Duration(days: 365)),
                onSelected: (selectedDate) {
                  setState(() {
                    expirationDateTimestamp = selectedDate.millisecondsSinceEpoch;
                  });
                },
              ),
            ),
          ] else ...[
            const Spacer(),
          ],
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          // Monto a la izquierda
          Flexible(
            child: TitleTextField(
              title: "Monto*",
              initialValue: widget.expense != null
                  ? NumberFormatter.convertFromCentsToUnitsCurrency(amountInCents)
                  : null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              validator: (value) {
                if (value == null || value.isEmpty) return "El monto es requerido";
                final parsed = double.tryParse(value.replaceAll(',', ''));
                if (parsed == null) return "Monto inválido";
                amountInCents = (parsed * 100).toInt();
                widget.creationMap['amount'] = amountInCents;
                return null;
              },
            ),
          ),
          // Un spacer a la derecha para que ocupe mitad del ancho y guarde simetría con los campos superiores
          const SizedBox(width: 12),
          const Spacer(),
        ],
      ),
      const SizedBox(height: 12),
      TitleTextField(
        title: "Descripción",
        initialValue: widget.expense?.description,
        maxLines: 3,
        validator: (value) {
          widget.creationMap['description'] = value?.trim();
          return null;
        },
      ),
    ];

    void submitAction() {
      if (!widget.formKey.currentState!.validate()) return;

      final authCubit = getIt<AuthCubit>();
      widget.creationMap['branchId'] = authCubit.currentBranchId;
      widget.creationMap['dateId'] = dateTimestamp.toString();
      widget.creationMap['status'] = isCredit ? ExpenseStatus.open.name : ExpenseStatus.paid.name;
      widget.creationMap['expirationDate'] = isCredit ? expirationDateTimestamp : null;
      widget.creationMap['createdBy'] = UserInfo(
        id: authCubit.user?.id ?? "",
        name: authCubit.user?.username ?? "",
      ).toJson();

      if (widget.expense == null) {
        final createExpense = CreateExpense.fromJson(widget.creationMap);
        writeCubit.create(createExpense);
      } else {
        final updateExpense = UpdateExpense.fromJson(widget.creationMap);
        writeCubit.update(widget.expense!.id, updateExpense);
      }
    }

    if (context.isMobile()) {
      return Scaffold(
        appBar: AppBar(
          title: Text("$wordPrefix Gasto por Proveedor"),
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            height: 60,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: submitAction,
                      child: Text("$wordPrefix Gasto"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Card(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(8),
                  children: fields,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AlertDialog(
          insetPadding: EdgeInsets.zero,
          title: Text("$wordPrefix Gasto por Proveedor"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: fields,
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: submitAction,
              child: Text("$wordPrefix Gasto"),
            ),
          ],
        ),
      ],
    );
  }
}
