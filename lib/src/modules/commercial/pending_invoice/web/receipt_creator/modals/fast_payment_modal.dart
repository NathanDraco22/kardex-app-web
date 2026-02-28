import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';

Future<double?> showFastPaymentModal(
  BuildContext context, {
  required double maxAmountToPay,
  required String clientName,
}) {
  return showDialog<double>(
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
  double _currentInput = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Current input converted to cents for exact comparison
    final inputCents = (_currentInput * 100).round();
    final maxCents = (widget.maxAmountToPay * 100).round();

    final isValid = inputCents > 0 && inputCents <= maxCents;
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
              const SizedBox(height: 24),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Monto a Abonar (Efectivo)",
                  border: const OutlineInputBorder(),
                  prefixText: "\$ ",
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
                  if (isValid) {
                    Navigator.pop(context, _currentInput);
                  }
                },
              ),
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
                    onPressed: isValid
                        ? () {
                            Navigator.pop(context, _currentInput);
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
