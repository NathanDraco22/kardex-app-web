import 'package:material_ui/material_ui.dart';
import 'package:kardex_business/kardex_business.dart';
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
  return showDialog<FastPaymentResult>(
    context: context,
    builder: (context) => FastPaymentModal(
      maxAmountToPay: maxAmountToPay,
      clientName: clientName,
    ),
  );
}

class FastPaymentModal extends StatefulWidget {
  const FastPaymentModal({
    super.key,
    required this.maxAmountToPay,
    required this.clientName,
  });

  final double maxAmountToPay;
  final String clientName;

  @override
  State<FastPaymentModal> createState() => _FastPaymentModalState();
}

class _FastPaymentModalState extends State<FastPaymentModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  double _currentInput = 0.0;
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _useSecondaryCurrency = false;
  String? _selectedBank;

  int _tenderedCents() => NumberFormatter.convertFromDoubleToCents(_currentInput);

  int _convertedPrimaryCents(PaymentCurrencySettings settings) {
    final tendered = _tenderedCents();
    if (!_useSecondaryCurrency) return tendered;
    return NumberFormatter.convertSecondaryToPrimaryCents(
      tendered,
      settings.exchangeRate,
    );
  }

  int _appliedPrimaryCents(PaymentCurrencySettings settings) {
    final maxCents = (widget.maxAmountToPay * 100).round();
    final primary = _convertedPrimaryCents(settings);
    if (_useSecondaryCurrency && primary > maxCents) {
      return maxCents;
    }
    return primary;
  }

  int _changePrimaryCents(PaymentCurrencySettings settings) {
    if (_selectedMethod != PaymentMethod.cash || !_useSecondaryCurrency) {
      return 0;
    }
    final maxCents = (widget.maxAmountToPay * 100).round();
    final primary = _convertedPrimaryCents(settings);
    return primary > maxCents ? primary - maxCents : 0;
  }

  void _submit(PaymentCurrencySettings settings) {
    if (!_canConfirmFor(settings)) return;
    final appliedCents = _appliedPrimaryCents(settings);
    final detail = _selectedMethod == PaymentMethod.cash
        ? buildPaymentDetail(
            useSecondary: _useSecondaryCurrency,
            tenderedCents: _tenderedCents(),
            changePrimaryCents: _changePrimaryCents(settings),
            settings: settings,
          )
        : null;
    Navigator.pop(
      context,
      FastPaymentResult(
        amount: appliedCents / 100.0,
        method: _selectedMethod,
        bankReference: _selectedMethod == PaymentMethod.cash
            ? ""
            : formatBankReference(
                bank: _selectedBank,
                reference: _refController.text,
              ),
        paymentDetail: detail,
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  bool _canConfirmFor(PaymentCurrencySettings settings) {
    final maxCents = (widget.maxAmountToPay * 100).round();
    if (maxCents <= 0) return false;
    if (_selectedMethod == PaymentMethod.cash &&
        _useSecondaryCurrency &&
        !settings.hasValidExchangeRate) {
      return false;
    }
    final tenderedCents = _tenderedCents();
    if (tenderedCents <= 0) return false;

    final primaryCents = _convertedPrimaryCents(settings);
    if (primaryCents <= 0) return false;
    if (!_useSecondaryCurrency && primaryCents > maxCents) return false;

    if (_selectedMethod == PaymentMethod.cash) return true;
    return _refController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final currencySettings = PaymentCurrencySettings.fromContext(context);
    final tenderedCents = _tenderedCents();
    final convertedPrimaryCents = _convertedPrimaryCents(currencySettings);
    final appliedPrimaryCents = _appliedPrimaryCents(currencySettings);
    final changePrimaryCents = _changePrimaryCents(currencySettings);
    final maxCents = (widget.maxAmountToPay * 100).round();
    final canConfirm = _canConfirmFor(currencySettings);

    final maxAmountFormatted = NumberFormatter.convertToMoneyLike(maxCents);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber.shade900),
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
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
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
              if (_selectedMethod == PaymentMethod.cash &&
                  currencySettings.canUseDifferentSecondary) ...[
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
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                inputFormatters: [const DecimalTextInputFormatter()],
                decoration: InputDecoration(
                  labelText: "Monto a Abonar",
                  border: const OutlineInputBorder(),
                  prefixText: _useSecondaryCurrency
                      ? '${currencySettings.secondaryCurrency.symbol} '
                      : '${currencySettings.primaryCurrency.symbol} ',
                  errorText: () {
                    if (tenderedCents <= 0 && _amountController.text.isNotEmpty) {
                      return "Ingrese un monto mayor a 0";
                    }
                    if (!_useSecondaryCurrency && convertedPrimaryCents > maxCents) {
                      return "El monto excede la deuda total";
                    }
                    return null;
                  }(),
                ),
                onChanged: (value) {
                  setState(() {
                    _currentInput = double.tryParse(value) ?? 0.0;
                  });
                },
                onSubmitted: (_) => _submit(currencySettings),
              ),
              if (_useSecondaryCurrency &&
                  currencySettings.hasValidExchangeRate &&
                  tenderedCents > 0) ...[
                const SizedBox(height: 8),
                Text(
                  changePrimaryCents > 0
                      ? 'Equivalente: ${NumberFormatter.formatMoney(convertedPrimaryCents, currencySettings.primaryCurrency)} (Se aplican ${NumberFormatter.formatMoney(appliedPrimaryCents, currencySettings.primaryCurrency)})'
                      : 'Equivalente a abonar: ${NumberFormatter.formatMoney(appliedPrimaryCents, currencySettings.primaryCurrency)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (changePrimaryCents > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Cambio: ${formatPaymentChangeLabel(changePrimaryCents, primaryCurrency: currencySettings.primaryCurrency, secondaryCurrency: currencySettings.secondaryCurrency, exchangeRate: currencySettings.exchangeRate)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  decoration: const InputDecoration(
                    labelText: "Número de Referencia",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 16),
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
    );
  }
}
