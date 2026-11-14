import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/cash_movements_list_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/close_shift_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/shift_viewer_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_business/kardex_business.dart';

class ShiftManagementDialog extends StatelessWidget {
  final ShiftInDb shift;

  const ShiftManagementDialog({super.key, required this.shift});

  static Future<void> show(BuildContext context, {required ShiftInDb shift}) {
    return showDialog<void>(
      context: context,
      builder: (context) => ShiftManagementDialog(shift: shift),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemeTokens.success.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: AppThemeTokens.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turno #${shift.docNumber} Activo',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${shift.branchName} • Fondo: ${NumberFormatter.convertToMoneyLike(shift.initialCash)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionTile(
              icon: Icons.swap_vert_rounded,
              color: AppThemeTokens.indigo,
              title: 'Movimientos de Efectivo',
              subtitle: 'Visualiza, registra o anula entradas y salidas de caja',
              onTap: () async {
                Navigator.of(context).pop();
                await showCashMovementsListDialog(context, shift: shift);
              },
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.receipt_long_rounded,
              color: Colors.teal,
              title: 'Ver Movimientos / Pre-Arqueo',
              subtitle: 'Consulta el detalle en vivo y movimientos del turno',
              onTap: () async {
                Navigator.of(context).pop();
                await ShiftViewerDialog.show(context, shift: shift);
              },
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.lock_clock_rounded,
              color: AppThemeTokens.danger,
              title: 'Cerrar / Arquear Turno',
              subtitle: 'Realiza el conteo de efectivo y cierra tu turno',
              onTap: () async {
                Navigator.of(context).pop();
                await CloseShiftDialog.show(context, shift: shift);
              },
            ),
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
