import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

class PaymentResult {
  final PaymentType method;
  final int amountReceived;
  final String? reference;

  PaymentResult({
    required this.method,
    required this.amountReceived,
    this.reference,
  });
}

Future<PaymentResult?> showPaymentConfirmationDialog(
  BuildContext context,
  int total,
) async {
  PaymentResult? result;

  await showDialog(
    context: context,
    builder: (context) {
      return _PaymentDialog(total: total);
    },
  ).then((value) => result = value);

  return result;
}

class _PaymentDialog extends StatefulWidget {
  final int total;
  const _PaymentDialog({required this.total});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  PaymentType _selectedMethod = PaymentType.cash;
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  int _receivedAmount = 0;

  @override
  void dispose() {
    _receivedController.dispose();
    _refController.dispose();
    super.dispose();
  }

  int get _change {
    if (_selectedMethod != PaymentType.cash) return 0;
    final change = _receivedAmount - widget.total;
    return change > 0 ? change : 0;
  }

  bool get _canConfirm {
    if (_selectedMethod == PaymentType.cash) {
      return _receivedAmount >= widget.total;
    }
    return _refController.text.isNotEmpty;
  }

  @override
  Widget build(context) {
    return AlertDialog(
      title: const Text("Confirmar Pago", textAlign: TextAlign.center),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total a Pagar: ${NumberFormatter.convertToMoneyLike(widget.total)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SegmentedButton<PaymentType>(
              segments: const [
                ButtonSegment(
                  value: PaymentType.cash,
                  label: Text("Efectivo"),
                  icon: Icon(Icons.money),
                ),
                ButtonSegment(
                  value: PaymentType.card,
                  label: Text("Tarjeta"),
                  icon: Icon(Icons.credit_card),
                ),
                ButtonSegment(
                  value: PaymentType.transfer,
                  label: Text("Transf."),
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
            if (_selectedMethod == PaymentType.cash) ...[
              TextField(
                controller: _receivedController,
                inputFormatters: [DecimalTextInputFormatter()],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Dinero Recibido",
                  prefixText: "\$",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _receivedAmount = ((double.tryParse(value) ?? 0) * 100).toInt();
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Cambio: ${NumberFormatter.convertToMoneyLike(_change)}",
                style: TextStyle(
                  fontSize: 18,
                  color: _change >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              TextField(
                controller: _refController,
                inputFormatters: [IntegerTextInputFormatter()],
                decoration: const InputDecoration(
                  labelText: "Número de Referencia",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: CustomSlider(
                    hintText: "Desliza para Confirmar",
                    hintIcon: Icons.check_circle,
                    sliderColor: _canConfirm ? Colors.green : Colors.grey,
                    sliderText: "Confirmar",
                    onSubmit: () {
                      if (_canConfirm) {
                        return;
                      }
                      context.pop(
                        PaymentResult(
                          method: _selectedMethod,
                          amountReceived: _selectedMethod == PaymentType.cash ? _receivedAmount : widget.total,
                          reference: _selectedMethod == PaymentType.cash ? null : _refController.text,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
