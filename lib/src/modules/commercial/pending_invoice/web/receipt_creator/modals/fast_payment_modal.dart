import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/bank_chips_selector.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/payment_currency_selector.dart';

class FastPaymentResult {
  final double amount;
  final PaymentMethod method;
  final String bankReference;
  final PaymentDetail? paymentDetail;

  FastPaymentResult({
    required this.amount,
    required this.method,
    required this.bankReference,
    this.paymentDetail,
  });
}

Future<FastPaymentResult?> showFastPaymentModal(
  BuildContext context, {
  required double maxAmountToPay,
  required String clientName,
}) {
  final useReceivedAmount = _useAbonoReceivedAmount(context);
  return showDialog<FastPaymentResult>(
    context: context,
    builder: (context) => FastPaymentModal(
      maxAmountToPay: maxAmountToPay,
      clientName: clientName,
      useReceivedAmount: useReceivedAmount,
    ),
  );
}

/// Lee la bandera de `AppSettings` con un fallback conservador para pruebas o
/// contextos sin el cubit.
bool _useAbonoReceivedAmount(BuildContext context) {
  try {
    return context.read<AppSettingsCubit>().policy.useAbonoReceivedAmount;
  } catch (_) {
    return false;
  }
}

class FastPaymentModal extends StatefulWidget {
  const FastPaymentModal({
    super.key,
    required this.maxAmountToPay,
    required this.clientName,
    this.useReceivedAmount = false,
  });

  final double maxAmountToPay;
  final String clientName;
  final bool useReceivedAmount;

  @override
  State<FastPaymentModal> createState() => _FastPaymentModalState();
}

class _FastPaymentModalState extends State<FastPaymentModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  final FocusNode _receivedFocusNode = FocusNode();
  double _currentAmount = 0.0;
  double _currentReceived = 0.0;
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _useSecondaryCurrency = false;
  String? _selectedBank;

  AbonoPaymentPolicy get _paymentPolicy => AbonoPaymentPolicy(useReceivedAmount: widget.useReceivedAmount);

  int _amountInputCents() => NumberFormatter.convertFromDoubleToCents(_currentAmount);

  int _receivedInputCents() => NumberFormatter.convertFromDoubleToCents(_currentReceived);

  AbonoPaymentDecision _evaluate(PaymentCurrencySettings settings) {
    final maxCents = (widget.maxAmountToPay * 100).round();
    return _paymentPolicy.evaluate(
      method: _selectedMethod,
      maxDebtCents: maxCents,
      appliedInputCents: _amountInputCents(),
      receivedInputCents: _receivedInputCents(),
      useSecondaryCurrency: _useSecondaryCurrency,
      primaryCurrency: settings.primaryCurrency,
      secondaryCurrency: settings.secondaryCurrency,
      exchangeRate: settings.exchangeRate,
      hasValidExchangeRate: settings.hasValidExchangeRate,
      hasReference: _refController.text.trim().isNotEmpty,
    );
  }

  void _submit(PaymentCurrencySettings settings) {
    final decision = _evaluate(settings);
    if (!decision.isValid) return;

    Navigator.pop(
      context,
      FastPaymentResult(
        amount: decision.appliedPrimaryCents / 100.0,
        method: _selectedMethod,
        bankReference: _selectedMethod == PaymentMethod.cash
            ? ""
            : formatBankReference(
                bank: _selectedBank,
                reference: _refController.text,
              ),
        paymentDetail: decision.paymentDetail,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _receivedController.dispose();
    _refController.dispose();
    _receivedFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySettings = PaymentCurrencySettings.fromContext(context);
    final decision = _evaluate(currencySettings);
    final canConfirm = decision.isValid;
    final maxCents = (widget.maxAmountToPay * 100).round();
    final maxAmountFormatted = NumberFormatter.convertToMoneyLike(maxCents);

    final showCashAmountSummary =
        decision.isValid &&
        _selectedMethod == PaymentMethod.cash &&
        _amountInputCents() > 0 &&
        (widget.useReceivedAmount ||
            (_useSecondaryCurrency && currencySettings.hasValidExchangeRate) ||
            decision.changePrimaryCents > 0);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Abono Rápido - ${widget.clientName}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Deuda total: $maxAmountFormatted",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (maxCents <= 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.amber.shade900,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Las devoluciones o notas de crédito cubren o superan el adeudo de facturas. No es posible abonar un monto adicional.",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SegmentedButton<PaymentMethod>(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.black;
                    }),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: PaymentMethod.cash,
                      label: Text("Efectivo", style: TextStyle(fontSize: 16)),
                      icon: Icon(Icons.money),
                    ),
                    ButtonSegment(
                      value: PaymentMethod.card,
                      label: Text("Tarjeta", style: TextStyle(fontSize: 16)),
                      icon: Icon(Icons.credit_card),
                    ),
                    ButtonSegment(
                      value: PaymentMethod.transfer,
                      label: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text("Transf.", style: TextStyle(fontSize: 16)),
                      ),
                      icon: Icon(Icons.account_balance),
                    ),
                  ],
                  selected: {_selectedMethod},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedMethod = newSelection.first;
                      if (_selectedMethod == PaymentMethod.cash) {
                        _selectedBank = null;
                      } else {
                        _useSecondaryCurrency = false;
                      }
                    });
                  },
                ),
                if (_selectedMethod == PaymentMethod.cash && currencySettings.canUseDifferentSecondary) ...[
                  const SizedBox(height: 16),
                  PaymentCurrencySelector(
                    settings: currencySettings,
                    useSecondary: _useSecondaryCurrency,
                    onChanged: (useSecondary) {
                      setState(() => _useSecondaryCurrency = useSecondary);
                    },
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  key: const Key('fast-payment-amount-field'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  inputFormatters: const [DecimalTextInputFormatter()],
                  decoration: InputDecoration(
                    labelText: "Monto a Abonar",
                    border: const OutlineInputBorder(),
                    prefixText: _useSecondaryCurrency
                        ? '${currencySettings.secondaryCurrency.symbol} '
                        : '${currencySettings.primaryCurrency.symbol} ',
                    errorText: () {
                      if (_amountInputCents() <= 0 && _amountController.text.isNotEmpty) {
                        return "Ingrese un monto mayor a 0";
                      }
                      if (decision.error == AbonoPaymentError.amountExceedsDebt) {
                        return "El monto excede la deuda total";
                      }
                      return null;
                    }(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _currentAmount = double.tryParse(value) ?? 0.0;
                    });
                  },
                  onSubmitted: (_) {
                    if (widget.useReceivedAmount && _selectedMethod == PaymentMethod.cash) {
                      _receivedFocusNode.requestFocus();
                      return;
                    }
                    _submit(currencySettings);
                  },
                ),
                if (_selectedMethod == PaymentMethod.cash && widget.useReceivedAmount) ...[
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('fast-payment-received-field'),
                    controller: _receivedController,
                    focusNode: _receivedFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [DecimalTextInputFormatter()],
                    decoration: InputDecoration(
                      labelText: "Dinero Recibido",
                      border: const OutlineInputBorder(),
                      prefixText: _useSecondaryCurrency
                          ? '${currencySettings.secondaryCurrency.symbol} '
                          : '${currencySettings.primaryCurrency.symbol} ',
                      helperText:
                          (_useSecondaryCurrency && currencySettings.hasValidExchangeRate && _receivedInputCents() > 0)
                          ? 'Equivalente: ${NumberFormatter.formatMoney(NumberFormatter.convertSecondaryToPrimaryCents(_receivedInputCents(), currencySettings.exchangeRate), currencySettings.primaryCurrency)}'
                          : null,
                      errorText: decision.error == AbonoPaymentError.receivedBelowApplied
                          ? "El dinero recibido no cubre el abono"
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentReceived = double.tryParse(value) ?? 0.0;
                      });
                    },
                    onSubmitted: (_) => _submit(currencySettings),
                  ),
                ],
                if (showCashAmountSummary) ...[
                  const SizedBox(height: 8),
                  if (_useSecondaryCurrency) ...[
                    Text(
                      decision.changePrimaryCents > 0
                          ? 'Equivalente: ${NumberFormatter.formatMoney(decision.receivedPrimaryCents, currencySettings.primaryCurrency)} (Se aplican ${NumberFormatter.formatMoney(decision.appliedPrimaryCents, currencySettings.primaryCurrency)})'
                          : 'Equivalente a abonar: ${NumberFormatter.formatMoney(decision.appliedPrimaryCents, currencySettings.primaryCurrency)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Se aplican: ${NumberFormatter.formatMoney(decision.appliedPrimaryCents, currencySettings.primaryCurrency)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                  if (widget.useReceivedAmount || decision.changePrimaryCents > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cambio: ${formatPaymentChangeLabel(decision.changePrimaryCents, primaryCurrency: currencySettings.primaryCurrency, secondaryCurrency: _useSecondaryCurrency ? currencySettings.secondaryCurrency : null, exchangeRate: _useSecondaryCurrency ? currencySettings.exchangeRate : null)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: decision.changePrimaryCents > 0 ? Colors.green : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ],
                if (_selectedMethod != PaymentMethod.cash) ...[
                  const SizedBox(height: 14),
                  BankChipsSelector(
                    selectedBank: _selectedBank,
                    onChanged: (bank) => setState(() => _selectedBank = bank),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _refController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    inputFormatters: [IntegerTextInputFormatter()],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Número de Referencia",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    PrimaryMenuButton(
                      onPressed: canConfirm ? () => _submit(currencySettings) : null,
                      label: const Text("Aplicar Abono"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
