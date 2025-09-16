part of '../client_account_screen.dart';

class ClientAccountWeb extends StatelessWidget {
  const ClientAccountWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebScaffold();
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estado de cuenta de Clientes")),
      body: BlocBuilder<ReadClientCubit, ReadClientState>(
        builder: (context, state) {
          if (state is ReadClientLoading || state is ReadClientInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ClientReadError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const _WebBody();
        },
      ),
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
          children: [
            SizedBox(height: 12),

            Expanded(
              child: ClientsTable(),
            ),
          ],
        ),
      ),
    );
  }
}
