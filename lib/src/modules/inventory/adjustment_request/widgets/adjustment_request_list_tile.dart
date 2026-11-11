import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

import 'adjustment_request_status_chip.dart';

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
  });

  final AdjustmentRequestInDb request;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(request.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
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
  });

  final AdjustmentRequestInDb request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(request.createdAt);

    return Material(
      color: Colors.white,
      borderRadius: AppThemeTokens.borderRadiusLg,
      child: InkWell(
        borderRadius: AppThemeTokens.borderRadiusLg,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: AppThemeTokens.borderRadiusLg,
            border: Border.all(color: AppThemeTokens.borderLight),
            boxShadow: AppThemeTokens.subtleCardShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.docNumber,
                      style: const TextStyle(
                        fontSize: 15,
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
              Text(
                '${DateTimeTool.formatddMMyy(createdAt)} · ${DateTimeTool.formatHHmm(createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 15, color: AppThemeTokens.neutral),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.createdBy.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                    ),
                  ),
                  const Icon(Icons.inventory_2_outlined, size: 15, color: AppThemeTokens.neutral),
                  const SizedBox(width: 4),
                  Text(
                    '${request.items.length} ítems',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppThemeTokens.borderLight),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MiniTotal(
                      label: 'Sobrante',
                      value: NumberFormatter.convertToMoneyLike(request.entryTotal),
                      color: AppThemeTokens.success,
                    ),
                  ),
                  Container(width: 1, height: 28, color: AppThemeTokens.borderLight),
                  Expanded(
                    child: _MiniTotal(
                      label: 'Faltante',
                      value: NumberFormatter.convertToMoneyLike(request.exitTotal),
                      color: AppThemeTokens.danger,
                      alignEnd: true,
                    ),
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

class _MiniTotal extends StatelessWidget {
  const _MiniTotal({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppThemeTokens.neutral,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}
