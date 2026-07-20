import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/widgets/dialogs/shorcut_container.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class ExtraUnitsEditorResult {
  final List<ExtraUnit> extraUnits;
  final int defaultUnitIndex;
  final int wholesaleUnitIndex;

  ExtraUnitsEditorResult({
    required this.extraUnits,
    required this.defaultUnitIndex,
    required this.wholesaleUnitIndex,
  });
}

Future<ExtraUnitsEditorResult?> showProductExtraUnitsEditor(
  BuildContext context, {
  required List<ExtraUnit> initialExtraUnits,
  required int initialDefaultUnitIndex,
  required int initialWholesaleUnitIndex,
  required String baseUnitName,
}) async {
  return await showDialog<ExtraUnitsEditorResult?>(
    context: context,
    builder: (context) {
      return ExtraUnitsEditorDialog(
        initialExtraUnits: initialExtraUnits,
        initialDefaultUnitIndex: initialDefaultUnitIndex,
        initialWholesaleUnitIndex: initialWholesaleUnitIndex,
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
    required this.initialWholesaleUnitIndex,
    required this.baseUnitName,
  });

  final List<ExtraUnit> initialExtraUnits;
  final int initialDefaultUnitIndex;
  final int initialWholesaleUnitIndex;
  final String baseUnitName;

  @override
  State<ExtraUnitsEditorDialog> createState() => _ExtraUnitsEditorDialogState();
}

class _ExtraUnitsEditorDialogState extends State<ExtraUnitsEditorDialog> {
  late List<ExtraUnit> extraUnits;
  late int defaultUnitIndex;
  late int wholesaleUnitIndex;

  @override
  void initState() {
    super.initState();
    extraUnits = List.from(widget.initialExtraUnits);
    defaultUnitIndex = widget.initialDefaultUnitIndex;
    wholesaleUnitIndex = widget.initialWholesaleUnitIndex;
    _validateDefaultUnitIndex();
    _validateWholesaleUnitIndex();
  }

  void _validateDefaultUnitIndex() {
    if (defaultUnitIndex > extraUnits.length) {
      defaultUnitIndex = 0;
    }
  }

  void _validateWholesaleUnitIndex() {
    if (wholesaleUnitIndex > extraUnits.length) {
      wholesaleUnitIndex = 0;
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

        if (wholesaleUnitIndex == index + 1) {
          wholesaleUnitIndex = 0;
        } else if (wholesaleUnitIndex > index + 1) {
          wholesaleUnitIndex--;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUnitName = widget.baseUnitName.isEmpty ? 'Unidad Base' : widget.baseUnitName;
    final defaultUnitNameText = defaultUnitIndex == 0 ? baseUnitName : extraUnits[defaultUnitIndex - 1].name;

    return ShortcutContainer(
      child: AlertDialog(
        title: const Text('Unidades de Medida Extra'),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (extraUnits.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay unidades de medida extra configuradas.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.separated(
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
                const Text(
                  'Unidad Mayorista',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: wholesaleUnitIndex,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text('Usar Unidad por Defecto ($defaultUnitNameText)'),
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
                        wholesaleUnitIndex = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              Builder(
                builder: (context) {
                  RegisShortcutNotification(onAdd: () => _addExtraUnit()).dispatch(context);
                  return ElevatedButton.icon(
                    autofocus: true,
                    onPressed: _addExtraUnit,
                    icon: const Icon(Icons.add),
                    label: const Text("Añadir Unidad Extra"),
                  );
                },
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
                wholesaleUnitIndex: wholesaleUnitIndex,
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
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

    void addAction() {
      if (formKey.currentState!.validate()) {
        final newUnit = ExtraUnit(
          name: map['name'] as String,
          conversionFactor: map['conversionFactor'] as int,
        );
        Navigator.pop(context, newUnit);
      }
    }

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
                    autofocus: true,
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
                    onEditingComplete: addAction,
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
              onPressed: addAction,
              child: Text(isEditing ? "Guardar Cambios" : "Agregar"),
            ),
          ],
        );
      },
    );
  }
}
