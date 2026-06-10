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
  ExpenseType selectedType = ExpenseType.operative;
  int amountInCents = 0;
  int dateTimestamp = DateTime.now().millisecondsSinceEpoch;
  bool isCredit = false;
  int? expirationDateTimestamp;

  @override
  void initState() {
    super.initState();
    widget.creationMap['type'] = selectedType.name;
    if (widget.expense != null) {
      amountInCents = widget.expense!.amount;
      dateTimestamp = widget.expense!.date;
      isCredit = widget.expense!.status != ExpenseStatus.paid;
      expirationDateTimestamp = widget.expense!.expirationDate;
      widget.creationMap['docNumber'] = widget.expense!.docNumber;
      widget.creationMap['category'] = widget.expense!.category;
      widget.creationMap['description'] = widget.expense!.description;
    } else {
      isCredit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<WriteExpenseCubit>();
    final wordPrefix = widget.expense == null ? "Crear" : "Actualizar";

    widget.creationMap['supplierId'] = "";
    widget.creationMap['amount'] = amountInCents;
    widget.creationMap['date'] = dateTimestamp;

    final fields = [
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
                  if (isCredit && expirationDateTimestamp == null) {
                    expirationDateTimestamp = DateTime.now().millisecondsSinceEpoch;
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
                          if (isCredit && expirationDateTimestamp == null) {
                            expirationDateTimestamp = DateTime.now().millisecondsSinceEpoch;
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
          Flexible(
            child: ExpenseCategoryDropdown(
              value: widget.creationMap['category'] as String?,
              isRequired: true,
              label: "Categoría",
              onChanged: (value) {
                setState(() {
                  widget.creationMap['category'] = value;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "La categoría es requerida";
                }
                widget.creationMap['category'] = value.trim();
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
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
          title: Text("$wordPrefix Gasto"),
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
          title: Text("$wordPrefix Gasto"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields,
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
