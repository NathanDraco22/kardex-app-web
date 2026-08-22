part of '../adjust_exit_screen.dart';

class AdjustExitWebScreen extends StatelessWidget {
  const AdjustExitWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebScaffold();
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustExitMediator.read(context);
    final type = viewController.type;
    String title = switch (type) {
      .adjust => "Salida por Ajuste de Inventario",
      .devolution => "Devoluciones",
      .loss => "Mermas",
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () async {
            final allFields = viewController.hasAllRequiredFields;
            if (!allFields) {
              context.pop();
              return;
            }
            final res = await DialogManager.confirmActionDialog(
              context,
              "¿Deseas salir sin guardar? (Perderás los cambios)",
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const _WebBody(),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: _HeaderSection(),
            ),
            SizedBox(height: 8),
            Flexible(
              fit: FlexFit.tight,
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
