import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

class InvoiceDevolutionTile extends StatelessWidget {
  const InvoiceDevolutionTile({
    super.key,
    required this.invoice,
    required this.devolutions,
    this.creditNotes = const [],
    required this.isSelected,
    required this.onChanged,
    required this.onViewInvoice,
    required this.onViewDevolutions,
    required this.onViewReceipts,
    this.onViewCreditNotes,
    this.tileColor,
  });

  final InvoiceInDb invoice;
  final List<DevolutionInDb> devolutions;
  final List<CreditNoteInDb> creditNotes;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onViewInvoice;
  final VoidCallback onViewDevolutions;
  final VoidCallback onViewReceipts;
  final VoidCallback? onViewCreditNotes;
  final Color? tileColor;

  Widget _buildSummaryItem(String label, int amount, {Color? color, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            NumberFormatter.convertToMoneyLike(amount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetDevolution = devolutions.where((d) => d.originalInvoiceId == invoice.id).toList();
    final bool hasOpenDevolutions = targetDevolution.any((d) => d.status == DevolutionStatus.open);
    final bool hasConfirmedDevolutions =
        targetDevolution.isNotEmpty && targetDevolution.every((d) => d.status == DevolutionStatus.confirmed);
    final bool isDisabled = hasOpenDevolutions;

    final targetCreditNotes = creditNotes
        .where(
          (cn) =>
              cn.invoiceId == invoice.id ||
              (cn.invoiceDocNumber.isNotEmpty && cn.invoiceDocNumber == invoice.docNumber),
        )
        .toList();

    final int devolutionsTotal = targetDevolution.fold(0, (sum, d) => sum + d.total);
    final int creditNotesTotal = targetCreditNotes.fold(0, (sum, cn) => sum + cn.total);
    final int adjustedTotal = invoice.totalRemaining - devolutionsTotal - creditNotesTotal;

    String docNumber = "#${invoice.docNumber}";
    if (docNumber.length > 14) {
      docNumber = docNumber.substring(0, 12);
    }

    final theme = Theme.of(context);
    final isSelectedColor = Colors.amber.shade50;
    final borderColor = isSelected
        ? Colors.amber.shade600
        : AppThemeTokens.borderLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? isSelectedColor : (tileColor ?? AppThemeTokens.cardBg),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.6 : 1.0,
        ),
        boxShadow: isSelected
            ? AppThemeTokens.subtleCardShadow(accent: Colors.amber)
            : AppThemeTokens.subtleCardShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppThemeTokens.borderRadiusMd,
          onLongPress: isDisabled ? null : () => onChanged(true),
          onTap: isDisabled ? null : () => onChanged(!isSelected),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila Superior: Checkbox + Folio + Fecha + Menú Más
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: isSelected,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeColor: Colors.amber.shade700,
                        onChanged: isDisabled ? null : onChanged,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Folio de la Factura
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            "Factura $docNumber",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDisabled ? Colors.grey : Colors.grey.shade900,
                            ),
                          ),
                          // Fecha de Emisión
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppThemeTokens.surfaceLight,
                              borderRadius: AppThemeTokens.borderRadiusSm,
                              border: Border.all(color: AppThemeTokens.borderLight, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 11,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateTimeTool.formatddMMyyEs(invoice.createdAt),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Botón Menú desplegable
                    PopupMenuButton<int>(
                      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade700),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: "Opciones de factura",
                      onSelected: (value) async {
                        if (value == 0) onViewInvoice();
                        if (value == 1) onViewDevolutions();
                        if (value == 2) onViewReceipts();
                        if (value == 3) onViewCreditNotes?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 18),
                              SizedBox(width: 8),
                              Text("Ver Factura"),
                            ],
                          ),
                        ),
                        if (hasOpenDevolutions || hasConfirmedDevolutions)
                          const PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.assignment_return_outlined, size: 18),
                                SizedBox(width: 8),
                                Text("Ver Devoluciones"),
                              ],
                            ),
                          ),
                        if (invoice.amountPaid > 0)
                          const PopupMenuItem(
                            value: 2,
                            child: Row(
                              children: [
                                Icon(Icons.receipt_outlined, size: 18),
                                SizedBox(width: 8),
                                Text("Ver Recibos"),
                              ],
                            ),
                          ),
                        if (targetCreditNotes.isNotEmpty)
                          const PopupMenuItem(
                            value: 3,
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 18),
                                SizedBox(width: 8),
                                Text("Ver Notas de Crédito"),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Bloque Bento con Detalles Financieros responsivos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppThemeTokens.surfaceLight,
                    borderRadius: AppThemeTokens.borderRadiusSm,
                    border: Border.all(
                      color: isSelected
                          ? Colors.amber.shade200
                          : AppThemeTokens.borderLight,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem("Total", invoice.total),
                      ),
                      Expanded(
                        child: _buildSummaryItem("Abonado", invoice.amountPaid, color: Colors.teal.shade700),
                      ),
                      if (targetDevolution.isNotEmpty)
                        Expanded(
                          child: _buildSummaryItem("Devolución", devolutionsTotal, color: Colors.orange.shade800),
                        ),
                      if (targetCreditNotes.isNotEmpty)
                        Expanded(
                          child: _buildSummaryItem("Nota Crédito", creditNotesTotal, color: AppThemeTokens.purple),
                        ),
                      Expanded(
                        child: _buildSummaryItem(
                          "Saldo Restante",
                          adjustedTotal,
                          isBold: true,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fila Inferior con Badges Contextuales si existen
                if (isDisabled || targetDevolution.isNotEmpty || targetCreditNotes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (isDisabled)
                        AppStatusBadge.danger(
                          label: "Devolución pendiente por confirmar",
                          icon: Icons.lock_outline,
                        ),
                      if (hasConfirmedDevolutions)
                        AppStatusBadge.warning(
                          label: "Devolución confirmada",
                          icon: Icons.assignment_return_outlined,
                        ),
                      if (targetCreditNotes.isNotEmpty)
                        AppStatusBadge.purple(
                          label: "${targetCreditNotes.length} Nota(s) de Crédito vinculada(s)",
                          icon: Icons.receipt_long_outlined,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
