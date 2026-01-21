import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

Future<bool> showConfirmEstimateDialog(
  BuildContext context, {
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmEstimateDialog(
      startDate: startDate,
      endDate: endDate,
    ),
  );
  return result ?? false;
}

class ConfirmEstimateDialog extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const ConfirmEstimateDialog({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ConfirmEstimateDialog> createState() => _ConfirmEstimateDialogState();
}

class _ConfirmEstimateDialogState extends State<ConfirmEstimateDialog> {
  int _secondsRemaining = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
      title: const Text("Estimar rotacion"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Estimar rotacion afectara a todas las sucursales, este proceso se realizara en todas las sucursales",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Periodo afectado:\n${DateTimeTool.formatddMMyyEs(widget.startDate)} | ${DateTimeTool.formatddMMyyEs(widget.endDate)}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _secondsRemaining == 0 ? () => Navigator.pop(context, true) : null,
          child: Text(
            _secondsRemaining > 0 ? "Confirmar ($_secondsRemaining)" : "Confirmar",
          ),
        ),
      ],
    );
  }
}
