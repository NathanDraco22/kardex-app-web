import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

class FastPaymentResult {
  final double amount;
  final PaymentMethod method;
  final String bankReference;

  FastPaymentResult({
    required this.amount,
    required this.method,
    required this.bankReference,
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

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    super.dispose();
  }

  bool get _canConfirm {
    final inputCents = (_currentInput * 100).round();
    final maxCents = (widget.maxAmountToPay * 100).round();
    final isAmountValid = inputCents > 0 && inputCents <= maxCents;
    if (!isAmountValid) return false;

    if (_selectedMethod == PaymentMethod.cash) return true;
    return _refController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Current input converted to cents for exact comparison
    final inputCents = (_currentInput * 100).round();
    final maxCents = (widget.maxAmountToPay * 100).round();

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
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                inputFormatters: [DecimalTextInputFormatter()],
                decoration: InputDecoration(
                  labelText: "Monto a Abonar",
                  border: const OutlineInputBorder(),
                  prefixText: r"$ ",
                  errorText: () {
                    if (inputCents <= 0 && _amountController.text.isNotEmpty) {
                      return "Ingrese un monto mayor a 0";
                    }
                    if (inputCents > maxCents) {
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
                onSubmitted: (value) {
                  if (_canConfirm) {
                    Navigator.pop(
                      context,
                      FastPaymentResult(
                        amount: _currentInput,
                        method: _selectedMethod,
                        bankReference: _selectedMethod == PaymentMethod.cash ? "" : _refController.text.trim(),
                      ),
                    );
                  }
                },
              ),
              if (_selectedMethod != PaymentMethod.cash) ...[
                const SizedBox(height: 16),
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
                  ElevatedButton(
                    onPressed: _canConfirm
                        ? () {
                            Navigator.pop(
                              context,
                              FastPaymentResult(
                                amount: _currentInput,
                                method: _selectedMethod,
                                bankReference: _selectedMethod == PaymentMethod.cash ? "" : _refController.text.trim(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Aplicar Abono"),
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
