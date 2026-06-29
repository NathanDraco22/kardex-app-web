part of '../inventory_entry_screen.dart';

class InventoryEntryScreenWeb extends StatelessWidget {
  const InventoryEntryScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => saveAction(context),
      },
      child: const Focus(
        autofocus: true,
        child: _WebScaffold(),
      ),
    );
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryEntryMediator.read(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrada de Inventario"),
        leading: IconButton(
          onPressed: () async {
            final allFields = mediator.hasAllRequiredFields();
            if (!allFields) {
              context.pop();
              return;
            }
            final res = await DialogManager.confirmActionDialog(
              context,
              "Deseas salir sin guardar? (Perderas los cambios)",
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
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
