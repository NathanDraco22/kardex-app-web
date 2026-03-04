import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<List<PersonalReference>?> showClientPersonalReferenceEditor(
  BuildContext context,
  List<PersonalReference> initialReferences,
) async {
  return await showDialog<List<PersonalReference>?>(
    context: context,
    builder: (context) {
      return PersonalReferencesEditorDialog(
        initialReferences: initialReferences,
      );
    },
  );
}

class PersonalReferencesEditorDialog extends StatefulWidget {
  const PersonalReferencesEditorDialog({
    super.key,
    required this.initialReferences,
  });

  final List<PersonalReference> initialReferences;

  @override
  State<PersonalReferencesEditorDialog> createState() => _PersonalReferencesEditorDialogState();
}

class _PersonalReferencesEditorDialogState extends State<PersonalReferencesEditorDialog> {
  late List<PersonalReference> references;

  @override
  void initState() {
    super.initState();
    references = List.from(widget.initialReferences);
  }

  void _addReference() async {
    final newRef = await _showAddEditReferenceDialog(context);
    if (newRef != null) {
      setState(() {
        references.add(newRef);
      });
    }
  }

  void _editReference(int index) async {
    final updatedRef = await _showAddEditReferenceDialog(context, referenceToEdit: references[index]);
    if (updatedRef != null) {
      setState(() {
        references[index] = updatedRef;
      });
    }
  }

  void _deleteReference(int index) async {
    final result = await DialogManager.confirmActionDialog(
      context,
      "¿Estás seguro de que deseas eliminar esta referencia personal?",
    );
    if (result) {
      setState(() {
        references.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Referencias Personales'),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: references.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay referencias personales.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: references.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final ref = references[index];
                        return ListTile(
                          title: Text(ref.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tel: ${ref.phone}"),
                              Text("Dir: ${ref.address}"),
                              Text("Ubic: ${ref.location}"),
                              if (ref.email != null && ref.email!.isNotEmpty) Text("Email: ${ref.email}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editReference(index),
                                tooltip: "Editar",
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteReference(index),
                                tooltip: "Eliminar",
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addReference,
              icon: const Icon(Icons.add),
              label: const Text("Añadir Referencia"),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => context.pop(null), // Changed to return null on cancel
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => context.pop(references),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<PersonalReference?> _showAddEditReferenceDialog(
    BuildContext context, {
    PersonalReference? referenceToEdit,
  }) async {
    final formKey = GlobalKey<FormState>();
    final isEditing = referenceToEdit != null;
    final map = <String, dynamic>{
      'name': referenceToEdit?.name ?? '',
      'phone': referenceToEdit?.phone ?? '',
      'address': referenceToEdit?.address ?? '',
      'location': referenceToEdit?.location ?? '',
      'email': referenceToEdit?.email ?? '',
    };

    return await showDialog<PersonalReference?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Editar Referencia" : "Añadir Referencia"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleTextField(
                    key: const ValueKey("ref_name"),
                    textInputAction: TextInputAction.next,
                    title: "Nombre Completo*",
                    initialValue: map['name'],
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Requerido";
                      map['name'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    key: const ValueKey("ref_phone"),
                    textInputAction: TextInputAction.next,
                    title: "Teléfono*",
                    initialValue: map['phone'],
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Requerido";
                      map['phone'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    key: const ValueKey("ref_location"),
                    textInputAction: TextInputAction.next,
                    title: "Ubicación (Ciudad)*",
                    initialValue: map['location'],
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Requerido";
                      map['location'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    key: const ValueKey("ref_address"),
                    textInputAction: TextInputAction.next,
                    title: "Dirección*",
                    initialValue: map['address'],
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Requerido";
                      map['address'] = value.trim();
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TitleTextField(
                    key: const ValueKey("ref_email"),
                    textInputAction: TextInputAction.done,
                    title: "Correo Electrónico (Opcional)",
                    initialValue: map['email'],
                    validator: (value) {
                      map['email'] = value?.trim();
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
                  final newRef = PersonalReference.fromJson(map);
                  Navigator.pop(context, newRef);
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
