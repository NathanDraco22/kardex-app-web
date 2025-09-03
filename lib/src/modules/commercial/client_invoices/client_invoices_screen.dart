import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class ClientInvoiceScreen extends StatelessWidget {
  const ClientInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Facturacion a Clientes"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          showSearchProductDialog(context);
        },
        child: const Text("ClientInvoicesScreen"),
      ),
    );
  }
}
