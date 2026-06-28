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
  });

  final String? value;
  final ValueChanged<String?>? onChanged;
  final String? Function(String?)? validator;
  final String label;
  final List<ExpenseCategoryInDb>? categories;
  final bool showAllOption;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    // Si no se pasaron categorías, las leemos del repositorio en el contexto
    final allCategories = categories ?? context.read<ExpenseCategoriesRepository>().expenseCategories;

    // Filtrar únicamente categorías activas y no eliminadas
    final filteredCategories = allCategories
        .where((c) => c.isActive && !c.isDeleted)
        .toList();

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

    return DropdownButtonFormField<String?>(
      initialValue: value == "" ? null : value,
      decoration: InputDecoration(
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
