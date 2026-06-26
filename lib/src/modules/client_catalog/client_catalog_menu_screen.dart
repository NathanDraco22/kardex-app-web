import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/user_role/modules.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/simple_search_dialog.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/clients_catalog_template.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import '../../domain/repositories/client_repository.dart';

class ClientCatalogMenuScreen extends StatelessWidget {
  const ClientCatalogMenuScreen({super.key});

  static final accessName = Modules.clients.name;

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Catalogo de Clientes")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(FluentIcons.person_12_filled),
            title: const Text("Lista de Clientes"),
            onTap: () {
              context.pushNamed("client-list");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded),
            title: const Text("Saldos Iniciales"),
            onTap: () {
              context.pushNamed("initial-balance");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(FluentIcons.search_12_filled),
            title: const Text("Buscar Cliente por #Cedula"),
            onTap: () {
              final clientRepo = context.read<ClientsRepository>();
              showSimpleSearchDialog(
                context,
                searchFuture: (value) {
                  if (value.isEmpty) {
                    return Future.error("La cedula no puede estar vacia");
                  }
                  return clientRepo.getClientByCardId(value.toUpperCase());
                },
                title: "Buscar Cliente por #Cedula",
                onResult: (value) {
                  showClientFullDetailsDialog(context, client: value);
                },
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.map_rounded),
            title: const Text("Mapa de Clientes"),
            onTap: () {
              context.pushNamed("client-map");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.group_work_rounded),
            title: const Text("Grupos de Clientes"),
            onTap: () {
              context.pushNamed("client-groups");
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Exportar Clientes (PDF)"),
            onTap: () async {
              LoadingDialogManager.showLoadingDialog(context);
              try {
                final clientRepo = context.read<ClientsRepository>();
                final clientsList = await clientRepo.getAllClients();
                final template = ClientsCatalogTemplate(
                  branchName: getIt<AuthCubit>().currentBranchName,
                  clients: clientsList,
                );
                await PdfExportTool.export(template, fileName: "catalogo_clientes.pdf");
                if (context.mounted) Navigator.pop(context); // Cerrar loader
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Cerrar loader
                  DialogManager.showErrorDialog(context, e.toString());
                }
              }
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(
            height: 0.0,
          ),
        ],
      ),
    );
  }
}
