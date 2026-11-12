import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestTotalsBar extends StatelessWidget {
  const AdjustmentRequestTotalsBar({
    super.key,
    required this.entryTotal,
    required this.exitTotal,
    this.itemCount,
    this.itemCountLabel = 'Productos',
    this.showNet = true,
    this.compact = false,
  });

  final int entryTotal;
  final int exitTotal;
  final int? itemCount;
  final String itemCountLabel;
  final bool showNet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final netTotal = entryTotal - exitTotal;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 18,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Wrap(
        spacing: compact ? 18 : 32,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (itemCount != null)
            _TotalItem(
              label: itemCountLabel,
              value: itemCount.toString(),
              color: AppThemeTokens.indigo,
              compact: compact,
            ),
          _TotalItem(
            label: 'Total sobrante',
            value: NumberFormatter.convertToMoneyLike(entryTotal),
            color: AppThemeTokens.success,
            compact: compact,
          ),
          _TotalItem(
            label: 'Total faltante',
            value: NumberFormatter.convertToMoneyLike(exitTotal),
            color: AppThemeTokens.danger,
            compact: compact,
          ),
          if (showNet)
            _TotalItem(
              label: 'Neto',
              value: NumberFormatter.convertToMoneyLike(netTotal),
              color: netTotal < 0 ? AppThemeTokens.danger : AppThemeTokens.neutral,
              compact: compact,
            ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: AppThemeTokens.neutral,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
