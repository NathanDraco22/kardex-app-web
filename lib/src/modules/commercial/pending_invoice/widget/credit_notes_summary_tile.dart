import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_app_front/widgets/design_system/app_status_badge.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';

class CreditNotesSummaryTile extends StatefulWidget {
  final List<CreditNoteInDb> creditNotes;

  const CreditNotesSummaryTile({
    super.key,
    required this.creditNotes,
  });

  @override
  State<CreditNotesSummaryTile> createState() => _CreditNotesSummaryTileState();
}

class _CreditNotesSummaryTileState extends State<CreditNotesSummaryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.creditNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalAmount = widget.creditNotes.fold<int>(
      0,
      (sum, item) => sum + item.total,
    );
    final count = widget.creditNotes.length;
    final totalFormatted = NumberFormatter.convertToMoneyLike(totalAmount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9FE),
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(
          color: AppThemeTokens.purple.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: AppThemeTokens.subtleCardShadow(accent: AppThemeTokens.purple),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: AppThemeTokens.borderRadiusLg,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppThemeTokens.purple.withValues(alpha: 0.12),
                      borderRadius: AppThemeTokens.borderRadiusMd,
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: AppThemeTokens.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Notas de Crédito a Favor",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppStatusBadge.purple(
                              label: count == 1 ? "1 nota" : "$count notas",
                              icon: Icons.check_circle_outline,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Saldo a favor disponible para deducir o amortizar en este cobro",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "- $totalFormatted",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppThemeTokens.purple,
                        ),
                      ),
                      Text(
                        _isExpanded ? "Ocultar detalle" : "Ver detalle",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppThemeTokens.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFEDE9FE)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              itemCount: widget.creditNotes.length,
              separatorBuilder: (context, index) => const Divider(
                height: 8,
                thickness: 0.5,
                color: Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                final cn = widget.creditNotes[index];
                final isDevolution = cn.type == CreditNoteType.devolution;
                final individualFormatted = NumberFormatter.convertToMoneyLike(cn.total);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDevolution
                              ? AppThemeTokens.teal.withValues(alpha: 0.1)
                              : AppThemeTokens.indigo.withValues(alpha: 0.1),
                          borderRadius: AppThemeTokens.borderRadiusSm,
                        ),
                        child: Icon(
                          isDevolution
                              ? Icons.assignment_return_outlined
                              : Icons.monetization_on_outlined,
                          size: 16,
                          color: isDevolution ? AppThemeTokens.teal : AppThemeTokens.indigo,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "#${cn.docNumber.isNotEmpty ? cn.docNumber : cn.id.substring(0, 8)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AppStatusBadge(
                                  label: isDevolution ? "Devolución" : "Por Monto",
                                  variant: isDevolution
                                      ? AppBadgeVariant.teal
                                      : AppBadgeVariant.indigo,
                                  fontSize: 10.5,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDevolution
                                  ? (cn.originalInvoiceDocNumber.isNotEmpty
                                      ? "Factura: #${cn.originalInvoiceDocNumber}"
                                      : "Vinculada a factura")
                                  : (cn.description.isNotEmpty
                                      ? cn.description
                                      : "Nota de crédito por monto"),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        individualFormatted,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: "Ver Nota de Crédito",
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: AppThemeTokens.purple,
                        ),
                        onPressed: () {
                          showCreditNoteViewerDialog(context, cn);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
