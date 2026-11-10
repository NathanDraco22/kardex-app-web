import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Buscador reactivo del catálogo de categorías.
class ExpenseCategorySearchBar extends StatelessWidget {
  const ExpenseCategorySearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar categoría por nombre o descripción...',
          hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onClear,
                ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      ),
    );
  }
}
