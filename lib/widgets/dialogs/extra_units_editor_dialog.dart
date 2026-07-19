import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class ExtraUnitsEditorResult {
  final List<ExtraUnit> extraUnits;
  final int defaultUnitIndex;

  ExtraUnitsEditorResult({
    required this.extraUnits,
    required this.defaultUnitIndex,
  });
}

Future<ExtraUnitsEditorResult?> showProductExtraUnitsEditor(
  BuildContext context, {
  required List<ExtraUnit> initialExtraUnits,
  required int initialDefaultUnitIndex,
  required String baseUnitName,
}) async {
  return await showDialog<ExtraUnitsEditorResult?>(
    context: context,
    builder: (context) {
      return ExtraUnitsEditorDialog(
        initialExtraUnits: initialExtraUnits,
        initialDefaultUnitIndex: initialDefaultUnitIndex,
        baseUnitName: baseUnitName,
      );
    },
  );
}

class ExtraUnitsEditorDialog extends StatefulWidget {
  const ExtraUnitsEditorDialog({
    super.key,
    required this.initialExtraUnits,
    required this.initialDefaultUnitIndex,
    required this.baseUnitName,
  });

  final List<ExtraUnit> initialExtraUnits;
  final int initialDefaultUnitIndex;
  final String baseUnitName;

  @override
  State<ExtraUnitsEditorDialog> createState() => _ExtraUnitsEditorDialogState();
}

class _ExtraUnitsEditorDialogState extends State<ExtraUnitsEditorDialog> {
  late List<ExtraUnit> extraUnits;
  late int defaultUnitIndex;

  @override
  void initState() {
    super.initState();
    extraUnits = List.from(widget.initialExtraUnits);
    defaultUnitIndex = widget.initialDefaultUnitIndex;
    _validateDefaultUnitIndex();
  }

  void _validateDefaultUnitIndex() {
    if (defaultUnitIndex > extraUnits.length) {
      defaultUnitIndex = 0;
    }
  }

  void _addExtraUnit() async {
    final newUnit = await _showAddEditExtraUnitDialog(context);
    if (newUnit != null) {
      setState(() {
        extraUnits.add(newUnit);
      });
    }
  }

  void _editExtraUnit(int index) async {
    final updatedUnit = await _showAddEditExtraUnitDialog(context, unitToEdit: extraUnits[index]);
    if (updatedUnit != null) {
      setState(() {
        extraUnits[index] = updatedUnit;
      });
    }
  }

  void _deleteExtraUnit(int index) async {
    final result = await DialogManager.confirmActionDialog(
      context,
      "¿Estás seguro de que deseas eliminar esta unidad de medida extra?",
    );
    if (result) {
      setState(() {
        extraUnits.removeAt(index);
        if (defaultUnitIndex == index + 1) {
          defaultUnitIndex = 0;
        } else if (defaultUnitIndex > index + 1) {
          defaultUnitIndex--;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUnitName = widget.baseUnitName.isEmpty ? 'Unidad Base' : widget.baseUnitName;

    return AlertDialog(
      title: const Text('Unidades de Medida Extra'),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: extraUnits.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay unidades de medida extra configuradas.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: extraUnits.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final extra = extraUnits[index];
                        final isDefault = defaultUnitIndex == index + 1;
                        return ListTile(
                          title: Text(extra.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Factor de conversión: ${extra.conversionFactor} ($baseUnitName)"),
                          leading: isDefault
                              ? const Icon(Icons.star, color: Colors.amber)
                              : const Icon(Icons.star_border, color: Colors.grey),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editExtraUnit(index),
                                tooltip: "Editar",
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExtraUnit(index),
                                tooltip: "Eliminar",
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (extraUnits.isNotEmpty) ...[
              const Text(
                'Unidad por Defecto para Mostrar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: defaultUnitIndex,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text('$baseUnitName (Unidad Base)'),
                  ),
                  ...List.generate(extraUnits.length, (index) {
                    final uName = extraUnits[index].name;
                    final factor = extraUnits[index].conversionFactor;
                    final label = uName.trim().isEmpty
                        ? 'Unidad Extra ${index + 1}'
                        : '$uName (x$factor $baseUnitName)';
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text(label),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      defaultUnitIndex = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _addExtraUnit,
              icon: const Icon(Icons.add),
              label: const Text("Añadir Unidad Extra"),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => context.pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => context.pop(
            ExtraUnitsEditorResult(
              extraUnits: extraUnits,
              defaultUnitIndex: defaultUnitIndex,
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<ExtraUnit?> _showAddEditExtraUnitDialog(
    BuildContext context, {
    ExtraUnit? unitToEdit,
  }) async {
    final formKey = GlobalKey<FormState>();
    final isEditing = unitToEdit != null;
    final map = <String, dynamic>{
      'name': unitToEdit?.name ?? '',
      'conversionFactor': unitToEdit?.conversionFactor ?? 1,
    };

    return await showDialog<ExtraUnit?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Editar Unidad Extra" : "Añadir Unidad Extra"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleTextField(
                    key: const ValueKey("unit_name"),
                    textInputAction: TextInputAction.next,
                    title: "Nombre de Unidad*",
                    initialValue: map['name'],
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Requerido";
                      map['name'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    key: const ValueKey("unit_conversion_factor"),
                    textInputAction: TextInputAction.done,
                    title: "Factor de Conversión*",
                    initialValue: map['conversionFactor'] == 1 ? '' : map['conversionFactor'].toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Requerido";
                      final factor = int.tryParse(value) ?? 0;
                      if (factor <= 1) return "Debe ser mayor a 1";
                      map['conversionFactor'] = factor;
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newUnit = ExtraUnit(
                    name: map['name'] as String,
                    conversionFactor: map['conversionFactor'] as int,
                  );
                  Navigator.pop(context, newUnit);
                }
              },
              child: Text(isEditing ? "Guardar Cambios" : "Agregar"),
            ),
          ],
        );
      },
    );
  }
}
