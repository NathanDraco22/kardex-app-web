import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_status_chip.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';

class AdjustmentRequestTableHeader extends StatelessWidget {
  const AdjustmentRequestTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w800,
      color: AppThemeTokens.neutral,
      letterSpacing: 0.2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: AppThemeTokens.surfaceLight,
        border: Border(bottom: BorderSide(color: AppThemeTokens.borderLight)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 14, child: Text('NO. SOLICITUD', style: style)),
          Expanded(flex: 14, child: Text('FECHA', style: style)),
          Expanded(flex: 18, child: Text('CREADO POR', style: style)),
          Expanded(flex: 12, child: Text('ESTADO', style: style)),
          Expanded(
            flex: 8,
            child: Text('ÍTEMS', style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 12,
            child: Text('SOBRANTE', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            flex: 12,
            child: Text('FALTANTE', style: style, textAlign: TextAlign.right),
          ),
          SizedBox(width: 28),
        ],
      ),
    );
  }
}

class AdjustmentRequestTableRow extends StatelessWidget {
  const AdjustmentRequestTableRow({
    super.key,
    required this.request,
    required this.onTap,
    this.showDivider = true,
    this.index = 0,
  });

  final AdjustmentRequestInDb request;
  final VoidCallback onTap;
  final bool showDivider;
  final int index;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(request.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: RowColorTool.getRowColor(index),
          border: showDivider ? const Border(bottom: BorderSide(color: AppThemeTokens.borderLight)) : null,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 14,
              child: Text(
                request.docNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Expanded(
              flex: 14,
              child: Text(
                '${DateTimeTool.formatddMMyy(createdAt)} · ${DateTimeTool.formatHHmm(createdAt)}',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              ),
            ),
            Expanded(
              flex: 18,
              child: Text(
                request.createdBy.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              ),
            ),
            Expanded(
              flex: 12,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AdjustmentRequestStatusChip(status: request.status),
              ),
            ),
            Expanded(
              flex: 8,
              child: Text(
                request.items.length.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 12,
              child: Text(
                NumberFormatter.convertToMoneyLike(request.entryTotal),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppThemeTokens.success,
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: Text(
                NumberFormatter.convertToMoneyLike(request.exitTotal),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppThemeTokens.danger,
                ),
              ),
            ),
            const SizedBox(
              width: 28,
              child: Icon(Icons.chevron_right_rounded, size: 20, color: AppThemeTokens.neutral),
            ),
          ],
        ),
      ),
    );
  }
}

class AdjustmentRequestCardTile extends StatelessWidget {
  const AdjustmentRequestCardTile({
    super.key,
    required this.request,
    required this.onTap,
    this.index = 0,
  });

  final AdjustmentRequestInDb request;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(request.createdAt);
    final netTotal = request.entryTotal - request.exitTotal;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: RowColorTool.getRowColor(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: No. de Solicitud y Estado
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.docNumber,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                AdjustmentRequestStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 6),

            // Metadatos: Fecha, Creador y Conteo de Ítems
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppThemeTokens.neutral),
                const SizedBox(width: 4),
                Text(
                  '${DateTimeTool.formatddMMyy(createdAt)} · ${DateTimeTool.formatHHmm(createdAt)}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.person_outline_rounded, size: 13, color: AppThemeTokens.neutral),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.createdBy.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                  ),
                ),
                const Icon(Icons.inventory_2_outlined, size: 13, color: AppThemeTokens.neutral),
                const SizedBox(width: 4),
                Text(
                  '${request.items.length} ítems',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Pastillas Bento de Totales
            Row(
              children: [
                Expanded(
                  child: _ListInfoPill(
                    label: 'Sobrante',
                    value: NumberFormatter.convertToMoneyLike(request.entryTotal),
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ListInfoPill(
                    label: 'Faltante',
                    value: NumberFormatter.convertToMoneyLike(request.exitTotal),
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ListInfoPill(
                    label: 'Total Neto',
                    value: NumberFormatter.convertToMoneyLike(netTotal),
                    color: netTotal >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                    isBold: true,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListInfoPill extends StatelessWidget {
  const _ListInfoPill({
    required this.label,
    required this.value,
    this.color,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.neutral,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
