import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/bank_chips_selector.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';
import 'package:kardex_app_front/widgets/payment_currency_selector.dart';

class PaymentResult {
  final PaymentType method;
  final int amountReceived;
  final String? reference;
  final PaymentDetail? paymentDetail;

  PaymentResult({
    required this.method,
    required this.amountReceived,
    this.reference,
    this.paymentDetail,
  });
}

Future<PaymentResult?> showPaymentConfirmationDialog(
  BuildContext context,
  int total, {
  bool showCredit = false,
  PaymentType initialMethod = PaymentType.cash,
}) async {
  PaymentResult? result;

  await showDialog(
    context: context,
    builder: (context) {
      return _PaymentDialog(
        total: total,
        showCredit: showCredit,
        initialMethod: initialMethod,
      );
    },
  ).then((value) => result = value);

  return result;
}

class _PaymentDialog extends StatefulWidget {
  final int total;
  final bool showCredit;
  final PaymentType initialMethod;

  const _PaymentDialog({
    required this.total,
    this.showCredit = false,
    this.initialMethod = PaymentType.cash,
  });

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  late PaymentType _selectedMethod;
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  int _receivedAmount = 0;
  bool _useSecondaryCurrency = false;
  String? _selectedBank;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  int _effectivePrimaryCents(PaymentCurrencySettings settings) {
    if (!_useSecondaryCurrency) return _receivedAmount;
    return NumberFormatter.convertSecondaryToPrimaryCents(
      _receivedAmount,
      settings.exchangeRate,
    );
  }

  int _changeFor(PaymentCurrencySettings settings) {
    if (_selectedMethod != PaymentType.cash) return 0;
    final change = _effectivePrimaryCents(settings) - widget.total;
    return change > 0 ? change : 0;
  }

  bool _canConfirmFor(PaymentCurrencySettings settings) {
    if (_selectedMethod == PaymentType.cash) {
      if (_useSecondaryCurrency && !settings.hasValidExchangeRate) {
        return false;
      }
      return _effectivePrimaryCents(settings) >= widget.total;
    }
    if (_selectedMethod == PaymentType.credit) {
      return true;
    }
    return _refController.text.isNotEmpty;
  }

  @override
  Widget build(context) {
    final currencySettings = PaymentCurrencySettings.fromContext(context);
    final canConfirm = _canConfirmFor(currencySettings);
    final change = _changeFor(currencySettings);
    final effectivePrimary = _effectivePrimaryCents(currencySettings);

    return AlertDialog(
      title: const Text("Confirmar Pago", textAlign: TextAlign.center),
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total a Pagar: ${NumberFormatter.convertToMoneyLike(widget.total)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SegmentedButton<PaymentType>(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black;
                }),
              ),
              segments: [
                const ButtonSegment(
                  value: PaymentType.cash,
                  label: Text("Efectivo", style: TextStyle(fontSize: 16)),
                  icon: Icon(Icons.money),
                ),
                const ButtonSegment(
                  value: PaymentType.card,
                  label: Text("Tarjeta", style: TextStyle(fontSize: 16)),
                  icon: Icon(Icons.credit_card),
                ),
                const ButtonSegment(
                  value: PaymentType.transfer,
                  label: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text("Transf.", style: TextStyle(fontSize: 16)),
                  ),
                  icon: Icon(Icons.account_balance),
                ),
                if (widget.showCredit)
                  const ButtonSegment(
                    value: PaymentType.credit,
                    label: Text("Crédito", style: TextStyle(fontSize: 16)),
                    icon: Icon(Icons.schedule),
                  ),
              ],
              selected: {_selectedMethod},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedMethod = newSelection.first;
                  if (_selectedMethod == PaymentType.cash ||
                      _selectedMethod == PaymentType.credit) {
                    _selectedBank = null;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            if (_selectedMethod == PaymentType.cash) ...[
              PaymentCurrencySelector(
                settings: currencySettings,
                useSecondary: _useSecondaryCurrency,
                onChanged: (useSecondary) {
                  setState(() => _useSecondaryCurrency = useSecondary);
                },
              ),
              if (currencySettings.canUseDifferentSecondary)
                const SizedBox(height: 12),
              TextField(
                controller: _receivedController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                inputFormatters: [const DecimalTextInputFormatter()],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Dinero Recibido",
                  prefixText: _useSecondaryCurrency
                      ? '${currencySettings.secondaryCurrency.symbol} '
                      : '${currencySettings.primaryCurrency.symbol} ',
                  helperText: (_useSecondaryCurrency &&
                          currencySettings.hasValidExchangeRate &&
                          _receivedAmount > 0)
                      ? 'Equivalente: ${NumberFormatter.formatMoney(effectivePrimary, currencySettings.primaryCurrency)}'
                      : null,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _receivedAmount =
                        NumberFormatter.convertFromDoubleToCents(
                          double.tryParse(value) ?? 0,
                        );
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Cambio: ${formatPaymentChangeLabel(change, primaryCurrency: currencySettings.primaryCurrency, secondaryCurrency: _useSecondaryCurrency ? currencySettings.secondaryCurrency : null, exchangeRate: _useSecondaryCurrency ? currencySettings.exchangeRate : null)}",
                style: TextStyle(
                  fontSize: 18,
                  color: change >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              if (_selectedMethod == PaymentType.card ||
                  _selectedMethod == PaymentType.transfer) ...[
                BankChipsSelector(
                  selectedBank: _selectedBank,
                  onChanged: (bank) => setState(() => _selectedBank = bank),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _refController,
                autofocus: true,
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
            const SizedBox(height: 30),
            AbsorbPointer(
              absorbing: !canConfirm,
              child: Row(
                children: [
                  Expanded(
                    child: CustomSlider(
                      hintText: "Desliza para Confirmar",
                      hintIcon: Icons.check_circle,
                      sliderColor: canConfirm ? Colors.green : Colors.grey,
                      sliderText: "Confirmar",
                      onSubmit: () {
                        if (!canConfirm) {
                          return;
                        }
                        final detail = _selectedMethod == PaymentType.cash
                            ? buildPaymentDetail(
                                useSecondary: _useSecondaryCurrency,
                                tenderedCents: _receivedAmount,
                                changePrimaryCents: change,
                                settings: currencySettings,
                              )
                            : null;
                        context.pop(
                          PaymentResult(
                            method: _selectedMethod,
                            amountReceived: _selectedMethod == PaymentType.cash ? effectivePrimary : widget.total,
                            reference: (_selectedMethod == PaymentType.cash || _selectedMethod == PaymentType.credit)
                                ? null
                                : formatBankReference(
                                    bank: _selectedBank,
                                    reference: _refController.text,
                                  ),
                            paymentDetail: detail,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
