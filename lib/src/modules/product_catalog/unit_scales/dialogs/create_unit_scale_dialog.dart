import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/write_unit_scale_cubit.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';
import 'package:kardex_business/kardex_business.dart';

Future<UnitScaleInDb?> showCreateOrEditUnitScaleDialog(
  BuildContext context, {
  UnitScaleInDb? scaleToEdit,
}) async {
  final cubit = context.read<WriteUnitScaleCubit>();

  return await showDialog<UnitScaleInDb?>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ClipRRect(
          borderRadius: AppThemeTokens.borderRadiusLg,
          child: BlocProvider.value(
            value: cubit,
            child: CreateUnitScaleDialog(scaleToEdit: scaleToEdit),
          ),
        ),
      );
    },
  );
}

class CreateUnitScaleDialog extends StatefulWidget {
  const CreateUnitScaleDialog({super.key, this.scaleToEdit});

  final UnitScaleInDb? scaleToEdit;

  @override
  State<CreateUnitScaleDialog> createState() => _CreateUnitScaleDialogState();
}

class _CreateUnitScaleDialogState extends State<CreateUnitScaleDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _baseUnitController;

  late List<ExtraUnit> _units;
  late int _defaultUnitIndex;
  late int _wholesaleUnitIndex;

  bool get isEditing => widget.scaleToEdit != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.scaleToEdit;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _baseUnitController = TextEditingController(text: edit?.baseUnit ?? '');
    _units = List<ExtraUnit>.from(edit?.units ?? []);
    _defaultUnitIndex = edit?.defaultUnitIndex ?? 0;
    _wholesaleUnitIndex = edit?.wholesaleUnitIndex ?? 0;
    _validateIndexes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUnitController.dispose();
    super.dispose();
  }

  void _validateIndexes() {
    if (_defaultUnitIndex > _units.length) _defaultUnitIndex = 0;
    if (_wholesaleUnitIndex > _units.length) _wholesaleUnitIndex = 0;
  }

  void _addExtraUnit() async {
    final newUnit = await _showAddEditUnitDialog(context);
    if (newUnit != null) {
      setState(() {
        _units.add(newUnit);
      });
    }
  }

  void _editExtraUnit(int index) async {
    final updatedUnit = await _showAddEditUnitDialog(
      context,
      unitToEdit: _units[index],
    );
    if (updatedUnit != null) {
      setState(() {
        _units[index] = updatedUnit;
      });
    }
  }

  void _deleteExtraUnit(int index) async {
    final confirmed = await DialogManager.confirmActionDialog(
      context,
      "¿Desea eliminar la unidad \"${_units[index].name}\" de la escala?",
    );
    if (!confirmed) return;

    setState(() {
      _units.removeAt(index);
      final unitIdx = index + 1;
      if (_defaultUnitIndex == unitIdx) {
        _defaultUnitIndex = 0;
      } else if (_defaultUnitIndex > unitIdx) {
        _defaultUnitIndex--;
      }

      if (_wholesaleUnitIndex == unitIdx) {
        _wholesaleUnitIndex = 0;
      } else if (_wholesaleUnitIndex > unitIdx) {
        _wholesaleUnitIndex--;
      }
    });
  }

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final baseUnit = _baseUnitController.text.trim();

    final title = isEditing
        ? "¿Desea actualizar la escala $name?"
        : "¿Desea registrar la escala $name?";

    final confirmed = await DialogManager.slideToConfirmActionDialog(context, title);
    if (!confirmed) return;
    if (!mounted) return;

    final cubit = context.read<WriteUnitScaleCubit>();

    if (isEditing) {
      final update = UpdateUnitScale(
        name: name,
        baseUnit: baseUnit,
        units: _units,
        defaultUnitIndex: _defaultUnitIndex,
        wholesaleUnitIndex: _wholesaleUnitIndex,
      );
      await cubit.updateUnitScale(widget.scaleToEdit!.id, update);
    } else {
      final create = CreateUnitScale(
        name: name,
        baseUnit: baseUnit,
        units: _units,
        defaultUnitIndex: _defaultUnitIndex,
        wholesaleUnitIndex: _wholesaleUnitIndex,
      );
      await cubit.createNewUnitScale(create);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUnitLabel =
        _baseUnitController.text.trim().isEmpty ? 'Unidad Base' : _baseUnitController.text.trim();

    return BlocListener<WriteUnitScaleCubit, WriteUnitScaleState>(
      listener: (context, state) {
        if (state is WriteUnitScaleInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteUnitScaleSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.scale);
        }
        if (state is WriteUnitScaleError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }
      },
      child: Container(
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cabecera Moderna
              AppDialogHeader(
                title: isEditing ? "Editar Escala de Unidades" : "Nueva Escala de Unidades",
                subtitle: "Configuración de factores de conversión y ventas sugeridas",
                icon: Icons.linear_scale_rounded,
                accentColor: AppThemeTokens.indigo,
                trailingBadge: isEditing
                    ? AppStatusBadge.info(label: "Edición")
                    : AppStatusBadge.success(label: "Nueva"),
                onClose: () => context.pop(),
              ),

              // Contenido con Formulario
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TitleTextField(
                                key: const ValueKey("scale_name"),
                                controller: _nameController,
                                title: "Nombre de la Escala*",
                                decoration: InputDecoration(
                                  hintText: "Ej. Peso, Volumen...",
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: AppThemeTokens.borderRadiusMd,
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppThemeTokens.borderRadiusMd,
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppThemeTokens.borderRadiusMd,
                                    borderSide: const BorderSide(color: AppThemeTokens.indigo, width: 1.5),
                                  ),
                                ),
                                textCapitalization: TextCapitalization.words,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Campo requerido";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TitleTextField(
                                key: const ValueKey("scale_base_unit"),
                                controller: _baseUnitController,
                                title: "Unidad Base (Mínima)*",
                                decoration: InputDecoration(
                                  hintText: "Ej. Gramo, Mililitro...",
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: AppThemeTokens.borderRadiusMd,
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppThemeTokens.borderRadiusMd,
                                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppThemeTokens.borderRadiusMd,
                                    borderSide: const BorderSide(color: AppThemeTokens.indigo, width: 1.5),
                                  ),
                                ),
                                textCapitalization: TextCapitalization.words,
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Campo requerido";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Unidades Adicionales (${_units.length})",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _addExtraUnit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppThemeTokens.indigo.withValues(alpha: 0.12),
                                foregroundColor: AppThemeTokens.indigo,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusSm),
                              ),
                              icon: const Icon(Icons.add_rounded, size: 17),
                              label: const Text("Agregar Unidad", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_units.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: AppThemeTokens.borderRadiusMd,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Center(
                              child: Text(
                                "No hay unidades agregadas.\nAgrega múltiplos basados en la unidad mínima ($baseUnitLabel).",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppThemeTokens.borderRadiusMd,
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _units.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              itemBuilder: (context, index) {
                                final u = _units[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppThemeTokens.indigo.withValues(alpha: 0.1),
                                          borderRadius: AppThemeTokens.borderRadiusSm,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppThemeTokens.indigo,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              u.name,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                            ),
                                            Text(
                                              "1 ${u.name} = ${u.conversionFactor} $baseUnitLabel",
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        onPressed: () => _editExtraUnit(index),
                                        tooltip: "Editar unidad",
                                        color: const Color(0xFF64748B),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                        onPressed: () => _deleteExtraUnit(index),
                                        tooltip: "Eliminar unidad",
                                        color: AppThemeTokens.danger,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 18),

                        const Text(
                          "Configuración de Venta Sugerida",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final defaultDropdown = DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Unidad por Defecto (Detalle)",
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                isDense: true,
                              ),
                              initialValue: _defaultUnitIndex <= _units.length ? _defaultUnitIndex : 0,
                              items: [
                                DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text(
                                    "$baseUnitLabel (Base)",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ...List.generate(
                                  _units.length,
                                  (i) => DropdownMenuItem<int>(
                                    value: i + 1,
                                    child: Text(
                                      _units[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _defaultUnitIndex = val);
                              },
                            );

                            final wholesaleDropdown = DropdownButtonFormField<int>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Unidad Mayorista Sugerida",
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                isDense: true,
                              ),
                              initialValue: _wholesaleUnitIndex <= _units.length ? _wholesaleUnitIndex : 0,
                              items: [
                                DropdownMenuItem<int>(
                                  value: 0,
                                  child: Text(
                                    "Misma que detalle / $baseUnitLabel",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                ...List.generate(
                                  _units.length,
                                  (i) => DropdownMenuItem<int>(
                                    value: i + 1,
                                    child: Text(
                                      _units[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _wholesaleUnitIndex = val);
                              },
                            );

                            if (constraints.maxWidth < 520) {
                              return Column(
                                children: [
                                  defaultDropdown,
                                  const SizedBox(height: 12),
                                  wholesaleDropdown,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: defaultDropdown),
                                const SizedBox(width: 12),
                                Expanded(child: wholesaleDropdown),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Botones Inferiores
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: const Text("Cancelar"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeTokens.indigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      ),
                      child: Text(
                        isEditing ? "Guardar Cambios" : "Crear Escala",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ExtraUnit?> _showAddEditUnitDialog(
    BuildContext context, {
    ExtraUnit? unitToEdit,
  }) async {
    final form = GlobalKey<FormState>();
    final isEdit = unitToEdit != null;
    final nameCtrl = TextEditingController(text: unitToEdit?.name ?? '');
    final factorCtrl = TextEditingController(
      text: unitToEdit != null ? unitToEdit.conversionFactor.toString() : '',
    );
    final baseLabel =
        _baseUnitController.text.trim().isEmpty ? 'unidad base' : _baseUnitController.text.trim();

    return await showDialog<ExtraUnit?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: AppThemeTokens.borderRadiusLg,
            child: Container(
              color: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppDialogHeader(
                      title: isEdit ? "Editar Unidad" : "Añadir Unidad",
                      subtitle: "Definir nombre y factor multiplicador",
                      icon: Icons.straighten_rounded,
                      accentColor: AppThemeTokens.indigo,
                      onClose: () => Navigator.pop(ctx),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TitleTextField(
                              controller: nameCtrl,
                              title: "Nombre de la Unidad*",
                              decoration: InputDecoration(
                                hintText: "Ej. Libra, Kilogramo, Litro...",
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return "Requerido";
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TitleTextField(
                              controller: factorCtrl,
                              title: "Factor de Conversión (en $baseLabel)*",
                              decoration: InputDecoration(
                                hintText: "Ej. 454 para Libra en Gramos",
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: AppThemeTokens.borderRadiusMd,
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return "Requerido";
                                final parsed = int.tryParse(val);
                                if (parsed == null || parsed <= 1) {
                                  return "Debe ser un número entero mayor a 1";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
                            ),
                            child: const Text("Cancelar"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (!form.currentState!.validate()) return;
                              final unit = ExtraUnit(
                                name: nameCtrl.text.trim(),
                                conversionFactor: int.parse(factorCtrl.text.trim()),
                              );
                              Navigator.pop(ctx, unit);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppThemeTokens.indigo,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: AppThemeTokens.borderRadiusMd),
                            ),
                            child: Text(isEdit ? "Guardar" : "Agregar"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
