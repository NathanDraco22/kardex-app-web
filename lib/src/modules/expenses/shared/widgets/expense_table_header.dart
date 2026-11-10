import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Medidas compartidas entre el encabezado y las filas de la tabla desktop.
class ExpenseTableLayout {
  const ExpenseTableLayout._();

  static const int conceptFlex = 4;
  static const int documentFlex = 2;
  static const int dateFlex = 2;
  static const int dueDateFlex = 2;
  static const int statusFlex = 4;
  static const int amountFlex = 2;

  static const double actionsWidth = 44;
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
}

/// Encabezado de columnas para la tabla de gastos en desktop.
class ExpenseTableHeader extends StatelessWidget {
  const ExpenseTableHeader({
    super.key,
    required this.conceptLabel,
  });

  final String conceptLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ExpenseTableLayout.horizontalPadding.copyWith(top: 11, bottom: 11),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: AppThemeTokens.borderLight),
        ),
      ),
      child: Row(
        children: [
          _headerCell(conceptLabel, flex: ExpenseTableLayout.conceptFlex),
          _headerCell('Documento', flex: ExpenseTableLayout.documentFlex),
          _headerCell('Registro', flex: ExpenseTableLayout.dateFlex),
          _headerCell('Vencimiento', flex: ExpenseTableLayout.dueDateFlex),
          _headerCell('Estado', flex: ExpenseTableLayout.statusFlex),
          _headerCell(
            'Monto',
            flex: ExpenseTableLayout.amountFlex,
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: ExpenseTableLayout.actionsWidth),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label, {
    required int flex,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
