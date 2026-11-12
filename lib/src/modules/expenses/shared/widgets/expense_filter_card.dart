import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Tarjeta de filtros colapsable para las vistas compactas de Gastos.
///
/// Replica el patrón del módulo de Solicitudes de Ajuste: una cabecera táctil
/// con el título "Filtros" y un chevron que expande o colapsa los controles.
/// El [footer] se mantiene siempre visible para no ocultar métricas.
class ExpenseFilterCard extends StatefulWidget {
  const ExpenseFilterCard({
    super.key,
    required this.child,
    this.footer,
    this.headerTrailing,
    this.initiallyExpanded = false,
  });

  /// Controles de filtrado que se muestran al expandir la tarjeta.
  final Widget child;

  /// Contenido persistente debajo de los filtros (p. ej. la franja de KPIs).
  final Widget? footer;

  /// Acción opcional siempre visible en la cabecera (p. ej. Exportar).
  final Widget? headerTrailing;

  /// Estado inicial del panel. En Gastos compactos inicia colapsado.
  final bool initiallyExpanded;

  @override
  State<ExpenseFilterCard> createState() => _ExpenseFilterCardState();
}

class _ExpenseFilterCardState extends State<ExpenseFilterCard> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _toggle,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(12, 10, 4, 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 18,
                          color: AppThemeTokens.indigo,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Filtros',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.headerTrailing != null) ...[
                widget.headerTrailing!,
                const SizedBox(width: 2),
              ],
              IconButton(
                tooltip: _expanded ? 'Ocultar filtros' : 'Mostrar filtros',
                onPressed: _toggle,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
          if (widget.footer != null) ...[
            const Divider(
              height: 1,
              thickness: 1,
              color: AppThemeTokens.borderLight,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: widget.footer!,
            ),
          ],
        ],
      ),
    );
  }
}
