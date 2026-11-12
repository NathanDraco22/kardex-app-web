import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

class ExpenseCategoryDropdown extends StatelessWidget {
  const ExpenseCategoryDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.validator,
    this.label = "Categoría",
    this.categories,
    this.showAllOption = false,
    this.isRequired = false,
    this.decoration,
    this.compact = false,
    this.accentColor,
  });

  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final String label;
  final List<ExpenseCategoryInDb>? categories;
  final bool showAllOption;
  final bool isRequired;
  final InputDecoration? decoration;
  final bool compact;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    // Si no se pasaron categorías, las leemos del repositorio en el contexto
    final allCategories = categories ?? context.read<ExpenseCategoriesRepository>().expenseCategories;

    // Filtrar únicamente categorías activas y no eliminadas
    final filteredCategories = allCategories.where((c) => c.isActive && !c.isDeleted).toList();

    // Si el valor actual no está en la lista filtrada pero no es nulo/vacío, lo agregamos para evitar que Dropdown aborte
    final hasValue = value != null && value!.isNotEmpty;
    final valueExistsInFiltered = filteredCategories.any((c) => c.name == value);

    // Si el valor actual existe en la lista general de categorías (pero desactivada o eliminada),
    // lo agregamos temporalmente para no causar error visual de selección.
    List<ExpenseCategoryInDb> finalCategories = [...filteredCategories];
    if (hasValue && !valueExistsInFiltered) {
      final matchingCategory = allCategories.firstWhere(
        (c) => c.name == value,
        orElse: () => ExpenseCategoryInDb(
          id: '',
          name: value!,
          createdAt: DateTime.now(),
          isActive: true,
          isDeleted: false,
        ),
      );
      finalCategories.add(matchingCategory);
    }

    // Ordenar alfabéticamente por nombre
    finalCategories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final currentValue = value == "" ? null : value;

    if (compact) {
      final effectiveAccent = accentColor ?? const Color(0xFF6366F1);
      final hasSelected = currentValue != null && currentValue.isNotEmpty;
      final displayText = currentValue ?? (showAllOption ? 'Todos' : 'Seleccionar');

      return Container(
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasSelected ? effectiveAccent.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: currentValue,
                      isExpanded: true,
                      isDense: true,
                      icon: const SizedBox.shrink(),
                      selectedItemBuilder: (context) {
                        return [
                          if (showAllOption)
                            const Text(
                              'Todos',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                                height: 1.0,
                              ),
                            ),
                          ...finalCategories.map(
                            (c) => Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                height: 1.0,
                              ),
                            ),
                          ),
                        ];
                      },
                      hint: Text(
                        displayText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: hasSelected ? FontWeight.w700 : FontWeight.w500,
                          color: hasSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                          height: 1.0,
                        ),
                      ),
                      items: [
                        if (showAllOption)
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                        ...finalCategories.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.name,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
            ),
            if (hasSelected && onChanged != null)
              IconButton(
                tooltip: 'Limpiar $label',
                icon: const Icon(Icons.close_rounded, size: 14),
                color: const Color(0xFF64748B),
                onPressed: () => onChanged!(null),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 22, height: 22),
                splashRadius: 12,
              )
            else
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String?>(
      initialValue: currentValue,
      // Ocupa todo el ancho disponible para que un nombre largo no fuerce al
      // botón a crecer más allá de su celda en los filtros.
      isExpanded: true,
      selectedItemBuilder: (context) {
        return [
          if (showAllOption) const _EllipsizedDropdownLabel("Todos"),
          ...finalCategories.map(
            (c) => _EllipsizedDropdownLabel(c.name),
          ),
        ];
      },
      decoration:
          decoration ??
          InputDecoration(
            border: const OutlineInputBorder(),
            label: Text(isRequired ? "$label*" : label),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
      items: [
        if (showAllOption)
          const DropdownMenuItem<String?>(
            value: null,
            child: Text("Todos"),
          ),
        ...finalCategories.map(
          (c) => DropdownMenuItem<String?>(
            value: c.name,
            child: Text(c.name),
          ),
        ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

/// Texto de una línea para el valor seleccionado del dropdown.
///
/// El menú desplegable conserva los nombres completos; solo el valor visible
/// dentro del campo se recorta para no desbordar.
class _EllipsizedDropdownLabel extends StatelessWidget {
  const _EllipsizedDropdownLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
