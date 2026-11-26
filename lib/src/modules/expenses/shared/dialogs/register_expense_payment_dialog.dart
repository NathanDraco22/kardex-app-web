import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_form_utils.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/widgets/expense_form_widgets.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

/// Abre el diálogo/pantalla para registrar un abono (parcial o total) a un gasto.
Future<ExpenseInDb?> showRegisterExpensePaymentDialog(
  BuildContext context, {
  required ExpenseInDb expense,
  bool prefillFullBalance = false,
  WriteExpenseCubit? writeCubit,
  UserInfo? currentUser,
}) async {
  if (!context.mounted) return null;

  final resolvedWriteCubit = writeCubit ?? context.read<WriteExpenseCubit>();
  final isMobile = MediaQuery.sizeOf(context).width < 700;

  if (isMobile) {
    return Navigator.of(context).push<ExpenseInDb>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: resolvedWriteCubit,
          child: RegisterExpensePaymentView(
            expense: expense,
            prefillFullBalance: prefillFullBalance,
            currentUser: currentUser,
            isFullScreen: true,
          ),
        ),
      ),
    );
  }

  return showDialog<ExpenseInDb>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: resolvedWriteCubit,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ClipRRect(
            borderRadius: AppThemeTokens.borderRadiusXl,
            child: Material(
              color: const Color(0xFFF8FAFC),
              child: RegisterExpensePaymentView(
                expense: expense,
                prefillFullBalance: prefillFullBalance,
                currentUser: currentUser,
                isFullScreen: false,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class RegisterExpensePaymentView extends StatefulWidget {
  const RegisterExpensePaymentView({
    super.key,
    required this.expense,
    this.prefillFullBalance = false,
    this.currentUser,
    this.isFullScreen = false,
  });

  final ExpenseInDb expense;
  final bool prefillFullBalance;
  final UserInfo? currentUser;
  final bool isFullScreen;

  @override
  State<RegisterExpensePaymentView> createState() => _RegisterExpensePaymentViewState();
}

class _RegisterExpensePaymentViewState extends State<RegisterExpensePaymentView> {
  static const Color _accentColor = Color(0xFFD97706);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  ExpensePaymentMethod _paymentMethod = ExpensePaymentMethod.cash;
  DateTime _paidAt = DateTime.now();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialAmount = widget.prefillFullBalance ? widget.expense.remainingAmount : 0;
    _amountController = TextEditingController(
      text: initialAmount > 0 ? formatExpenseAmountInput(initialAmount) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  UserInfo? _resolveCurrentUser() {
    if (widget.currentUser != null) return widget.currentUser;
    if (getIt.isRegistered<AuthCubit>()) {
      final user = getIt<AuthCubit>().user;
      if (user != null) {
        return UserInfo(id: user.id, name: user.username);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final formBody = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryHeaderCard(expense: widget.expense),
          const SizedBox(height: 12),
          ExpenseFormSection(
            title: 'Detalle del Abono',
            icon: Icons.payments_outlined,
            accentColor: _accentColor,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: expenseFormFieldDecoration(
                        label: 'Monto a abonar *',
                        hint: '0.00',
                        accentColor: _accentColor,
                        prefixIcon: const Icon(Icons.attach_money_rounded, size: 18),
                      ),
                      validator: (value) {
                        final cents = parseExpenseAmountCents(value ?? '');
                        if (cents == null) {
                          return 'Ingresa un monto válido mayor a cero';
                        }
                        if (cents > widget.expense.remainingAmount) {
                          return 'No puede exceder el saldo (${NumberFormatter.convertToMoneyLike(widget.expense.remainingAmount)})';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton.icon(
                      onPressed: _submitting ? null : _fillRemainingAmount,
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Saldo total'),
                      style: TextButton.styleFrom(
                        foregroundColor: _accentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExpensePaymentMethod>(
                initialValue: _paymentMethod,
                decoration: expenseFormFieldDecoration(
                  label: 'Método de pago',
                  accentColor: _accentColor,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                ),
                items: ExpensePaymentMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.displayLabel),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value != null) setState(() => _paymentMethod = value);
                      },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _submitting ? null : _pickDate,
                borderRadius: AppThemeTokens.borderRadiusMd,
                child: InputDecorator(
                  decoration: expenseFormFieldDecoration(
                    label: 'Fecha de pago',
                    accentColor: _accentColor,
                    prefixIcon: const Icon(Icons.calendar_today_rounded, size: 17),
                  ),
                  child: Text(
                    DateTimeTool.formatddMMyyEs(_paidAt),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _referenceController,
                decoration: expenseFormFieldDecoration(
                  label: 'Referencia / N° comprobante',
                  hint: 'Opcional (ej. transferencia #1234)',
                  accentColor: _accentColor,
                  prefixIcon: const Icon(Icons.tag_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: expenseFormFieldDecoration(
                  label: 'Nota',
                  hint: 'Observación adicional del abono (opcional)',
                  alignLabelWithHint: true,
                  accentColor: _accentColor,
                  prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppThemeTokens.danger.withValues(alpha: 0.08),
                borderRadius: AppThemeTokens.borderRadiusMd,
                border: Border.all(color: AppThemeTokens.danger.withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppThemeTokens.danger,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final footer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppThemeTokens.borderLight)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: const Color(0xFF334155),
                side: const BorderSide(color: AppThemeTokens.borderLight),
                shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_submitting ? 'Guardando...' : 'Registrar Abono'),
            ),
          ),
        ],
      ),
    );

    if (widget.isFullScreen) {
      return PopScope(
        canPop: !_submitting,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(title: const Text('Registrar Abono')),
          bottomNavigationBar: SafeArea(top: false, child: footer),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: formBody,
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: !_submitting,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogHeader(
            icon: Icons.payments_rounded,
            title: 'Registrar Abono',
            subtitle: widget.expense.supplierName.isNotEmpty
                ? widget.expense.supplierName
                : widget.expense.category,
            accentColor: _accentColor,
            onClose: () {
              if (!_submitting) Navigator.of(context).pop();
            },
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: formBody,
            ),
          ),
          footer,
        ],
      ),
    );
  }

  void _fillRemainingAmount() {
    setState(() {
      _amountController.text = formatExpenseAmountInput(widget.expense.remainingAmount);
      _errorMessage = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paidAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _paidAt = picked);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cents = parseExpenseAmountCents(_amountController.text);
    if (cents == null || cents <= 0 || cents > widget.expense.remainingAmount) return;

    setState(() => _submitting = true);

    final writeCubit = context.read<WriteExpenseCubit>();
    final updated = await writeCubit.addPayment(
      AddToAmountRequest(
        expenseId: widget.expense.id,
        amountPaid: cents,
        paymentMethod: _paymentMethod,
        reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        paidAt: _paidAt.millisecondsSinceEpoch,
        createdBy: _resolveCurrentUser(),
      ),
    );

    if (!mounted) return;
    if (updated != null) {
      Navigator.of(context).pop(updated);
      return;
    }

    final state = writeCubit.state;
    setState(() {
      _submitting = false;
      final rawMessage = state is WriteExpenseError ? state.message : 'No se pudo registrar el abono.';
      _errorMessage = rawMessage
          .replaceFirst('HttpServiceException: ', '')
          .replaceFirst('Exception: ', '');
    });
  }
}

class _SummaryHeaderCard extends StatelessWidget {
  const _SummaryHeaderCard({required this.expense});

  final ExpenseInDb expense;

  @override
  Widget build(BuildContext context) {
    final doc = expense.docNumber.trim().isEmpty ? 'S/N' : expense.docNumber;
    final concept = expense.supplierName.trim().isNotEmpty
        ? expense.supplierName
        : (expense.category.trim().isNotEmpty ? expense.category : 'Gasto');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  concept,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Doc. $doc',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _BalanceItem(
                  label: 'Total',
                  value: NumberFormatter.convertToMoneyLike(expense.amount),
                  color: const Color(0xFF334155),
                ),
              ),
              Expanded(
                child: _BalanceItem(
                  label: 'Abonado',
                  value: NumberFormatter.convertToMoneyLike(expense.effectiveAmountPaid),
                  color: AppThemeTokens.success,
                ),
              ),
              Expanded(
                child: _BalanceItem(
                  label: 'Saldo pendiente',
                  value: NumberFormatter.convertToMoneyLike(expense.remainingAmount),
                  color: AppThemeTokens.danger,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  const _BalanceItem({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
