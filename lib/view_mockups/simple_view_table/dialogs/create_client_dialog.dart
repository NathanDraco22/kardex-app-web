import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class CreateClientDialog extends StatelessWidget {
  const CreateClientDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar Nuevo Cliente"),
      actions: [
        OutlinedButton(
          onPressed: () {},
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text("Agregar Client"),
        ),
      ],
      content: const SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            TitleTextField(
              title: "Nombre",
            ),
            SizedBox(height: 12),
            Placeholder(),
          ],
        ),
      ),
    );
  }
}
