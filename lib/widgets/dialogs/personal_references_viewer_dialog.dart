import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';

void showClientPersonalReferenceViewer(
  BuildContext context,
  List<PersonalReference> references,
) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return PersonalReferencesViewerDialog(
        references: references,
      );
    },
  );
}

class PersonalReferencesViewerDialog extends StatelessWidget {
  const PersonalReferencesViewerDialog({
    super.key,
    required this.references,
  });

  final List<PersonalReference> references;

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
            if (references.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No hay referencias personales registradas.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
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
                          const SizedBox(height: 4),
                          Text("Tel: ${ref.phone}"),
                          Text("Dir: ${ref.address}"),
                          Text("Ubic: ${ref.location}"),
                          if (ref.email != null && ref.email!.isNotEmpty) Text("Email: ${ref.email}"),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
