import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShortcutsMenuScreen extends StatelessWidget {
  const ShortcutsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Atajos Rápidos"),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(
                FluentIcons.contact_card_24_filled,
                size: 32,
                color: Colors.indigo.shade400,
              ),
              title: const Text("Lista de Clientes (Crear Cliente)"),
              onTap: () {
                context.pushNamed("client-list");
              },
            ),
            const Divider(height: 0.0),
            ListTile(
              leading: Icon(
                FluentIcons.receipt_24_filled,
                size: 32,
                color: Colors.green.shade500,
              ),
              title: const Text("Facturación a Clientes"),
              onTap: () {
                context.pushNamed("client-invoice");
              },
            ),
            const Divider(height: 0.0),
            ListTile(
              leading: Icon(
                FluentIcons.receipt_add_24_filled,
                size: 32,
                color: Colors.blue.shade500,
              ),
              title: const Text("Facturación de Productos (Libre)"),
              onTap: () {
                context.pushNamed("anon-invoice");
              },
            ),
            const Divider(height: 0.0),
            ListTile(
              leading: Icon(
                FluentIcons.document_endnote_24_filled,
                size: 32,
                color: Colors.amber.shade600,
              ),
              title: const Text("Facturas por Cobrar"),
              onTap: () {
                context.pushNamed("pending-invoices");
              },
            ),
          ],
        ),
      ),
    );
  }
}
