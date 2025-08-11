part of '../inventory_entry_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 380,
          child: Card(
            margin: EdgeInsets.zero,

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TitleTextField(title: "Proveedor"),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(child: TitleTextField(title: "Documento")),
                      const SizedBox(width: 8),
                      Flexible(child: TitleTextField(title: "Fecha")),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 8),

        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
