import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/home/data/home_modules_registry.dart';
import 'package:kardex_app_front/widgets/gates/expiration_date_gate.dart';
import 'package:kardex_app_front/widgets/gates/orders_gate.dart';
import 'package:kardex_app_front/widgets/gates/quotations_gate.dart';
import 'package:kardex_app_front/widgets/gates/role_permission_gate.dart';
import 'package:kardex_app_front/widgets/dividers/menu_section_divider.dart';
import 'desktop_submenu_card.dart';

class DesktopSubmenuPanel extends StatefulWidget {
  final HomeModuleCategory category;

  const DesktopSubmenuPanel({
    super.key,
    required this.category,
  });

  @override
  State<DesktopSubmenuPanel> createState() => _DesktopSubmenuPanelState();
}

class _DesktopSubmenuPanelState extends State<DesktopSubmenuPanel> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = "";

  @override
  void didUpdateWidget(covariant DesktopSubmenuPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _searchController.clear();
      _filterQuery = "";
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final accent = category.accentColor;

    final filteredItems = category.submodules.where((item) {
      if (_filterQuery.isEmpty) return true;
      final q = _filterQuery.toLowerCase();
      final inTitle = item.title.toLowerCase().contains(q);
      final inSubtitle = item.subtitle?.toLowerCase().contains(q) ?? false;
      return inTitle || inSubtitle;
    }).toList();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, category, accent),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState(accent)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: _buildItemsList(context, filteredItems, accent),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    List<HomeSubmoduleItem> items,
    Color categoryAccent,
  ) {
    // Si hay búsqueda activa, mostramos la lista plana filtrada
    if (_filterQuery.isNotEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildItemWidget(context, items[index], categoryAccent);
        },
      );
    }

    // Comprobamos si los elementos tienen secciones
    final hasSections = items.any((i) => i.section != null);
    if (!hasSections) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _buildItemWidget(context, items[index], categoryAccent);
        },
      );
    }

    // Agrupamos por sección preservando el orden de inserción
    final Map<String, List<HomeSubmoduleItem>> sectionsMap = {};
    for (final item in items) {
      final sec = item.section ?? "Opciones";
      sectionsMap.putIfAbsent(sec, () => []).add(item);
    }

    final sectionWidgets = <Widget>[];
    int sectionIndex = 0;

    for (final entry in sectionsMap.entries) {
      final sectionName = entry.key;
      final sectionItems = entry.value;

      Widget divider = MenuSectionDivider(
        title: sectionName,
        isFirst: sectionIndex == 0,
        padding: EdgeInsets.only(
          top: sectionIndex == 0 ? 4 : 22,
          bottom: 8,
          left: 4,
          right: 4,
        ),
      );

      if (sectionName == "Cotizaciones y Proformas") {
        divider = QuotationsGate(child: divider);
      }

      sectionWidgets.add(divider);

      for (int i = 0; i < sectionItems.length; i++) {
        sectionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildItemWidget(context, sectionItems[i], categoryAccent),
          ),
        );
      }

      sectionIndex++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sectionWidgets,
    );
  }

  Widget _buildItemWidget(
    BuildContext context,
    HomeSubmoduleItem item,
    Color categoryAccent,
  ) {
    Widget card = DesktopSubmenuCard(
      item: item,
      accentColor: categoryAccent,
      onTap: () {
        if (item.customAction != null) {
          item.customAction!(context);
        } else if (item.routeName != null) {
          context.pushNamed(item.routeName!);
        }
      },
    );

    if (item.isExpirationGate) {
      card = ExpirationDateGate(child: card);
    }

    if (item.isOrdersGate) {
      card = OrdersGate(child: card);
    }

    if (item.isQuotationsGate) {
      card = QuotationsGate(child: card);
    }

    if (item.isQuotationsOrOrdersGate) {
      card = QuotationsOrOrdersGate(child: card);
    }

    if (item.permissions.isNotEmpty) {
      card = RolePermissionGate(
        permissions: item.permissions,
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader(BuildContext context, HomeModuleCategory category, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              category.icon,
              color: accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${category.submodules.length} opciones",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  category.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 260,
            height: 40,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filterQuery = val.trim()),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Buscar herramienta...",
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 19,
                  color: Colors.grey.shade500,
                ),
                suffixIcon: _filterQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filterQuery = "");
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: accent.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              "No se encontraron opciones para \"$_filterQuery\"",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Prueba con otro término de búsqueda.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _filterQuery = "");
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Restablecer búsqueda"),
            ),
          ],
        ),
      ),
    );
  }
}
