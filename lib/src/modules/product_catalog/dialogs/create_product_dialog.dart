import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class CreateProductDialog extends StatelessWidget {
  const CreateProductDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar Nuevo Producto"),
      actions: [
        OutlinedButton(
          onPressed: () {},
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text("Agregar Producto"),
        ),
      ],
      content: const SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            TitleTextField(
              title: "Nombre del Producto",
            ),
            SizedBox(height: 12),
            Placeholder(),
          ],
        ),
      ),
    );
  }
}
