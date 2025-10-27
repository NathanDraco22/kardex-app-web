import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/src/domain/models/expiration_log/expiration_log.dart';

Future<void> showExpirationLogViewerDialog(
  BuildContext context, {
  required ExpirationLogInDb log,
}) async {
  await showDialog(
    context: context,
    builder: (context) => _ExpirationLogViewer(log: log),
  );
}

class _ExpirationLogViewer extends StatelessWidget {
  const _ExpirationLogViewer({required this.log});

  final ExpirationLogInDb log;

  Widget _buildExpirationInfo(BuildContext context) {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final expiration = log.expirationDate;
    final difference = expiration.difference(now);
    final daysRemaining = difference.inDays;

    String text;
    Color color;

    if (daysRemaining < 0) {
      text = 'Vencido hace ${daysRemaining.abs()} días';
      color = Colors.red;
    } else if (daysRemaining == 0) {
      text = 'Vence hoy';
      color = Colors.orange;
    } else if (daysRemaining <= 100) {
      text = 'Vence en $daysRemaining días';
      color = Colors.amber.shade800;
    } else {
      text = 'Vence en $daysRemaining días';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Detalle de Vencimiento"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.product.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${log.product.brandName} - ${log.product.unitName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const Divider(height: 24),

            _InfoRow(title: 'Número de Lote', value: log.lotNumber ?? 'N/A'),
            _InfoRow(title: 'Fecha de Vencimiento', value: DateFormat('dd/MM/yyyy').format(log.expirationDate)),
            _InfoRow(title: 'Fecha de Registro', value: DateFormat('dd/MM/yyyy').format(log.createdAt)),
            const SizedBox(height: 16),

            _buildExpirationInfo(context),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
