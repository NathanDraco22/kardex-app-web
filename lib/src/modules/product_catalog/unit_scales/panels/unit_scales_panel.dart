import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/read_unit_scales_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/write_unit_scale_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/dialogs/create_unit_scale_dialog.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

/// Panel de gestión de escalas de unidades, reutilizable tanto en la pantalla
/// combinada de "Unidades y Escalas" como en la pantalla individual heredada.
class UnitScalesPanel extends StatefulWidget {
  const UnitScalesPanel({super.key});

  @override
  State<UnitScalesPanel> createState() => _UnitScalesPanelState();
}

class _UnitScalesPanelState extends State<UnitScalesPanel> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateDialog() async {
    final result = await showCreateOrEditUnitScaleDialog(context);
    if (result != null && mounted) {
      context.read<ReadUnitScalesCubit>().refreshUnitScales();
    }
  }

  void _openEditDialog(UnitScaleInDb scale) async {
    final result = await showCreateOrEditUnitScaleDialog(
      context,
      scaleToEdit: scale,
    );
    if (result != null && mounted) {
      context.read<ReadUnitScalesCubit>().refreshUnitScales();
    }
  }

  IconData _getScaleIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('peso') || lower.contains('masa') || lower.contains('kilo') || lower.contains('gramo')) {
      return Icons.scale_rounded;
    }
    if (lower.contains('volumen') ||
        lower.contains('litro') ||
        lower.contains('líquido') ||
        lower.contains('liquido')) {
      return Icons.water_drop_rounded;
    }
    if (lower.contains('longitud') || lower.contains('metro') || lower.contains('distancia')) {
      return Icons.straighten_rounded;
    }
    if (lower.contains('tiempo') || lower.contains('hora') || lower.contains('minuto')) {
      return Icons.access_time_filled_rounded;
    }
    return Icons.linear_scale_rounded;
  }

  Color _getScaleColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('peso')) return AppThemeTokens.teal;
    if (lower.contains('volumen')) return AppThemeTokens.info;
    if (lower.contains('longitud')) return AppThemeTokens.purple;
    if (lower.contains('tiempo')) return AppThemeTokens.warning;
    return AppThemeTokens.indigo;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<WriteUnitScaleCubit, WriteUnitScaleState>(
      listener: (context, state) {
        if (state is WriteUnitScaleInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        } else {
          LoadingDialogManager.closeLoadingDialog(context);
        }

        if (state is WriteUnitScaleError) {
          DialogManager.showErrorDialog(context, state.error);
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScalesHeader(onCreateScale: _openCreateDialog),
                const SizedBox(height: 12),

                // --- BANNER INFORMATIVO BENTO ---
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppThemeTokens.indigo.withValues(alpha: 0.06),
                    borderRadius: AppThemeTokens.borderRadiusMd,
                    border: Border.all(color: AppThemeTokens.indigo.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppThemeTokens.indigo.withValues(alpha: 0.12),
                          borderRadius: AppThemeTokens.borderRadiusSm,
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppThemeTokens.indigo, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Las escalas definen factores de conversión estandarizados (Peso, Volumen, Longitud, Tiempo). "
                          "Al asignar una escala a un producto, se precargan automáticamente sus unidades de venta y mayoreo.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // --- BARRA DE BÚSQUEDA ---
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar escala por nombre o unidad base...",
                    hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ReadUnitScalesCubit>().searchUnitScales("");
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    border: OutlineInputBorder(
                      borderRadius: AppThemeTokens.borderRadiusMd,
                      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppThemeTokens.borderRadiusMd,
                      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppThemeTokens.borderRadiusMd,
                      borderSide: const BorderSide(color: AppThemeTokens.indigo, width: 1.5),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() {});
                    context.read<ReadUnitScalesCubit>().searchUnitScales(val);
                  },
                ),
                const SizedBox(height: 16),

                // --- LISTADO DE ESCALAS ---
                Expanded(
                  child: BlocBuilder<ReadUnitScalesCubit, ReadUnitScalesState>(
                    builder: (context, state) {
                      if (state is ReadUnitScalesLoading || state is ReadUnitScalesInitial) {
                        return AppSkeletonLoader.cards(count: 4);
                      }

                      if (state is ReadUnitScalesError) {
                        return AppEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: "Error al cargar las escalas",
                          subtitle: state.message,
                          accentColor: AppThemeTokens.danger,
                          actionLabel: "Reintentar",
                          actionIcon: Icons.refresh_rounded,
                          onAction: () => context.read<ReadUnitScalesCubit>().refreshUnitScales(),
                        );
                      }

                      final scales = (state as ReadUnitScalesSuccess).scales;

                      if (scales.isEmpty) {
                        if (_searchController.text.isEmpty) {
                          return AppEmptyState(
                            icon: Icons.linear_scale_rounded,
                            title: "No hay escalas registradas",
                            subtitle: "Crea tu primera escala para estandarizar unidades de peso, volumen, etc.",
                            accentColor: AppThemeTokens.indigo,
                            actionLabel: "Nueva Escala",
                            actionIcon: Icons.add_rounded,
                            onAction: _openCreateDialog,
                          );
                        }

                        return AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: "Sin resultados para \"${_searchController.text}\"",
                          subtitle: "Verifica el término o restablece el buscador.",
                          accentColor: AppThemeTokens.indigo,
                          actionLabel: "Restablecer",
                          actionIcon: Icons.refresh_rounded,
                          onAction: () {
                            _searchController.clear();
                            context.read<ReadUnitScalesCubit>().searchUnitScales("");
                            setState(() {});
                          },
                        );
                      }

                      return ListView.separated(
                        itemCount: scales.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final scale = scales[index];
                          final icon = _getScaleIcon(scale.name);
                          final color = _getScaleColor(scale.name);

                          return _UnitScaleCard(
                            scale: scale,
                            icon: icon,
                            color: color,
                            onEdit: () => _openEditDialog(scale),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScalesHeader extends StatelessWidget {
  final VoidCallback onCreateScale;

  const _ScalesHeader({required this.onCreateScale});

  @override
  Widget build(BuildContext context) {
    const title = Text(
      'Escalas de conversión',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.2,
      ),
    );

    final button = ElevatedButton.icon(
      onPressed: onCreateScale,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppThemeTokens.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
      ),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text(
        'Nueva Escala',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 10),
              button,
            ],
          );
        }

        return Row(
          children: [
            const Expanded(child: title),
            const SizedBox(width: 12),
            button,
          ],
        );
      },
    );
  }
}

class _UnitScaleCard extends StatefulWidget {
  final UnitScaleInDb scale;
  final IconData icon;
  final Color color;
  final VoidCallback onEdit;

  const _UnitScaleCard({
    required this.scale,
    required this.icon,
    required this.color,
    required this.onEdit,
  });

  @override
  State<_UnitScaleCard> createState() => _UnitScaleCardState();
}

class _UnitScaleCardState extends State<_UnitScaleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final color = widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.008 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(
              color: _isHovered ? color.withValues(alpha: 0.45) : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered ? AppThemeTokens.hoverCardShadow(accent: color) : AppThemeTokens.subtleCardShadow(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila 1: Avatar, Nombre de la Escala y Acciones
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: AppThemeTokens.borderRadiusSm,
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                      ),
                      child: Icon(widget.icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        scale.name,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: "Editar escala",
                      color: const Color(0xFF64748B),
                      onPressed: widget.onEdit,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ÚLTIMA ROW: Badges tipo píldora en Wrap anti-overflow con ancho completo
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    AppStatusBadge.indigo(
                      label: "Base: ${scale.baseUnit}",
                      icon: Icons.straighten_rounded,
                    ),
                    if (scale.defaultUnitIndex > 0 && scale.defaultUnitIndex <= scale.units.length)
                      AppStatusBadge.warning(
                        label: "Detalle: ${scale.units[scale.defaultUnitIndex - 1].name}",
                        icon: Icons.storefront_rounded,
                      ),
                    if (scale.wholesaleUnitIndex > 0 && scale.wholesaleUnitIndex <= scale.units.length)
                      AppStatusBadge.success(
                        label: "Mayoreo: ${scale.units[scale.wholesaleUnitIndex - 1].name}",
                        icon: Icons.inventory_2_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Equivalencias en chips estilizados
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...scale.units.map(
                      (u) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: AppThemeTokens.borderRadiusSm,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          "${u.name} = ${u.conversionFactor} ${scale.baseUnit}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    if (scale.units.isEmpty)
                      Text(
                        "Sin unidades adicionales configuradas",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
