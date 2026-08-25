import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/custom_slider.dart';

class TerminalPaymentResult {
  final PaymentType method;
  final int amountReceived;
  final String? reference;
  final String? observations;

  TerminalPaymentResult({
    required this.method,
    required this.amountReceived,
    this.reference,
    this.observations,
  });
}

Future<TerminalPaymentResult?> showTerminalPaymentConfirmationDialog(
  BuildContext context,
  int total, {
  bool showCredit = false,
  PaymentType initialMethod = PaymentType.cash,
  String? initialObservations,
}) async {
  TerminalPaymentResult? result;

  await showDialog(
    context: context,
    builder: (context) {
      return _TerminalPaymentDialog(
        total: total,
        showCredit: showCredit,
        initialMethod: initialMethod,
        initialObservations: initialObservations,
      );
    },
  ).then((value) => result = value);

  return result;
}

class _TerminalPaymentDialog extends StatefulWidget {
  final int total;
  final bool showCredit;
  final PaymentType initialMethod;
  final String? initialObservations;

  const _TerminalPaymentDialog({
    required this.total,
    this.showCredit = false,
    this.initialMethod = PaymentType.cash,
    this.initialObservations,
  });

  @override
  State<_TerminalPaymentDialog> createState() => _TerminalPaymentDialogState();
}

class _TerminalPaymentDialogState extends State<_TerminalPaymentDialog> {
  late PaymentType _selectedMethod;
  final TextEditingController _receivedController = TextEditingController();
  final TextEditingController _refController = TextEditingController();
  late final TextEditingController _observationsController = TextEditingController(
    text: widget.initialObservations ?? "",
  );
  int _receivedAmount = 0;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.initialMethod;
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _refController.dispose();
    _observationsController.dispose();
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
    if (_selectedMethod == PaymentType.credit) {
      return true;
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
                });
              },
            ),
            const SizedBox(height: 20),
            if (_selectedMethod == PaymentType.cash) ...[
              TextField(
                controller: _receivedController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                inputFormatters: [DecimalTextInputFormatter()],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Dinero Recibido",
                  prefixText: "C\$",
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (![PaymentType.cash, PaymentType.credit].contains(_selectedMethod))
              TextField(
                controller: _refController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [IntegerTextInputFormatter()],
                decoration: const InputDecoration(
                  labelText: "Número de Referencia",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),

            const SizedBox(height: 12),
            TextField(
              controller: _observationsController,
              maxLines: 2,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: "Observaciones (opcional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            AbsorbPointer(
              absorbing: !_canConfirm,
              child: Row(
                children: [
                  Expanded(
                    child: CustomSlider(
                      hintText: "Desliza para Confirmar",
                      hintIcon: Icons.check_circle,
                      sliderColor: _canConfirm ? Colors.green : Colors.grey,
                      sliderText: "Confirmar",
                      onSubmit: () {
                        if (!_canConfirm) {
                          return;
                        }
                        final observations = _observationsController.text.trim();
                        context.pop(
                          TerminalPaymentResult(
                            method: _selectedMethod,
                            amountReceived: _selectedMethod == PaymentType.cash ? _receivedAmount : widget.total,
                            reference: (_selectedMethod == PaymentType.cash || _selectedMethod == PaymentType.credit)
                                ? null
                                : _refController.text,
                            observations: observations.isEmpty ? null : observations,
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
