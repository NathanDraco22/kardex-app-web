import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/read_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/dialog/create_unit_dialog.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Panel de gestión de unidades de medida, reutilizable tanto en la pantalla
/// combinada de "Unidades y Escalas" como en la pantalla individual heredada.
class UnitsPanel extends StatefulWidget {
  const UnitsPanel({super.key});

  @override
  State<UnitsPanel> createState() => _UnitsPanelState();
}

class _UnitsPanelState extends State<UnitsPanel> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog() async {
    final result = await showCreateUnitDialog(context);
    if (result == null || !mounted) return;

    await context.read<ReadUnitCubit>().refreshUnit();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unidad "${result.name}" agregada correctamente')),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ReadUnitCubit, ReadUnitState>(
      builder: (context, state) {
        if (state is ReadUnitLoading || state is ReadUnitInitial) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: AppSkeletonLoader.cards(count: 4),
            ),
          );
        }

        if (state is UnitReadError) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Error al cargar las unidades',
            subtitle: state.message,
            accentColor: AppThemeTokens.danger,
            actionLabel: 'Reintentar',
            actionIcon: Icons.refresh_rounded,
            onAction: () => context.read<ReadUnitCubit>().loadAllUnits(),
          );
        }

        final allUnits = (state as ReadUnitSuccess).units;
        final filteredUnits = _query.isEmpty
            ? allUnits
            : allUnits.where((unit) => unit.name.toLowerCase().contains(_query.toLowerCase())).toList();

        return _UnitsContent(
          allUnits: allUnits,
          units: filteredUnits,
          query: _query,
          searchController: _searchController,
          onSearchChanged: (value) => setState(() => _query = value.trim()),
          onClearSearch: _clearSearch,
          onCreateUnit: _openCreateDialog,
        );
      },
    );
  }
}

class _UnitsContent extends StatelessWidget {
  final List<UnitInDb> allUnits;
  final List<UnitInDb> units;
  final String query;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onCreateUnit;

  const _UnitsContent({
    required this.allUnits,
    required this.units,
    required this.query,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCreateUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _UnitsInfoBanner(),
              const SizedBox(height: 12),
              _UnitsToolbar(
                searchController: searchController,
                query: query,
                onSearchChanged: onSearchChanged,
                onClearSearch: onClearSearch,
                onCreateUnit: onCreateUnit,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Unidades registradas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppStatusBadge.info(
                    label: '${allUnits.length}',
                    icon: Icons.tag_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _UnitsList(
                  allUnits: allUnits,
                  units: units,
                  query: query,
                  onClearSearch: onClearSearch,
                  onCreateUnit: onCreateUnit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitsInfoBanner extends StatelessWidget {
  const _UnitsInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppThemeTokens.info.withValues(alpha: 0.06),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppThemeTokens.info.withValues(alpha: 0.12),
              borderRadius: AppThemeTokens.borderRadiusSm,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppThemeTokens.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Las unidades de medida son globales y se comparten con todos los productos. '
              'Agrega unidades como Unidad, Caja, Libra o Kilogramo para usarlas como base de los factores de conversión.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitsToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onCreateUnit;

  const _UnitsToolbar({
    required this.searchController,
    required this.query,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onCreateUnit,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Buscar unidad por nombre...',
        hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClearSearch,
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
      onChanged: onSearchChanged,
    );

    final addButton = PrimaryMenuButton(
      onPressed: onCreateUnit,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text(
        'Agregar Unidad',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              addButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: searchField),
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }
}

class _UnitsList extends StatelessWidget {
  final List<UnitInDb> allUnits;
  final List<UnitInDb> units;
  final String query;
  final VoidCallback onClearSearch;
  final VoidCallback onCreateUnit;

  const _UnitsList({
    required this.allUnits,
    required this.units,
    required this.query,
    required this.onClearSearch,
    required this.onCreateUnit,
  });

  @override
  Widget build(BuildContext context) {
    if (allUnits.isEmpty) {
      return AppEmptyState(
        icon: Icons.tag_rounded,
        title: 'No hay unidades registradas',
        subtitle: 'Agrega tu primera unidad de medida para empezar a configurar conversiones en tus productos.',
        accentColor: AppThemeTokens.info,
        actionLabel: 'Agregar Unidad',
        actionIcon: Icons.add_rounded,
        onAction: onCreateUnit,
      );
    }

    if (units.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Sin resultados para "$query"',
        subtitle: 'Verifica el término o restablece el buscador.',
        accentColor: AppThemeTokens.info,
        actionLabel: 'Restablecer',
        actionIcon: Icons.refresh_rounded,
        onAction: onClearSearch,
      );
    }

    return ListView.separated(
      itemCount: units.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _UnitCard(
        unit: units[index],
        index: index,
      ),
    );
  }
}

class _UnitCard extends StatefulWidget {
  final UnitInDb unit;
  final int index;

  const _UnitCard({
    required this.unit,
    required this.index,
  });

  @override
  State<_UnitCard> createState() => _UnitCardState();
}

class _UnitCardState extends State<_UnitCard> {
  bool _isHovered = false;

  static const List<Color> _colors = [
    AppThemeTokens.info,
    AppThemeTokens.teal,
    AppThemeTokens.indigo,
    AppThemeTokens.purple,
    AppThemeTokens.warning,
  ];

  static const List<IconData> _icons = [
    Icons.tag_rounded,
    Icons.straighten_rounded,
    Icons.scale_rounded,
    Icons.inventory_2_rounded,
    Icons.local_shipping_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[widget.index % _colors.length];
    final icon = _icons[widget.index % _icons.length];

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
              color: _isHovered ? color.withValues(alpha: 0.45) : AppThemeTokens.borderLight,
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered ? AppThemeTokens.hoverCardShadow(accent: color) : AppThemeTokens.subtleCardShadow(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppThemeTokens.borderRadiusSm,
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.unit.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unidad de medida · Registrada el ${DateTimeTool.formatddMMyyEs(widget.unit.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Tooltip(
                  message: 'Disponible para productos',
                  child: Icon(
                    Icons.verified_rounded,
                    color: AppThemeTokens.success,
                    size: 20,
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
