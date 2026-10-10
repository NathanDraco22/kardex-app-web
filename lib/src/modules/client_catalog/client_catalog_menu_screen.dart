import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/simple_search_dialog.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/clients_catalog_template.dart';

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
      appBar: AppBar(title: const Text("Catálogo de Clientes")),
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
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          ShortcutAddableListTile(
            routeName: RouteNames.clientList,
            child: MenuOptionCard(
              icon: FluentIcons.person_12_filled,
              accentColor: Colors.blue.shade600,
              title: "Lista de Clientes",
              subtitle: "Directorio general y administración de clientes",
              onTap: () => context.pushNamed("client-list"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.initialBalance,
            child: MenuOptionCard(
              icon: Icons.account_balance_wallet_rounded,
              accentColor: Colors.green.shade600,
              title: "Saldos Iniciales",
              subtitle: "Apertura y ajuste de saldo contable de clientes",
              onTap: () => context.pushNamed("initial-balance"),
            ),
          ),
          MenuOptionCard(
            icon: FluentIcons.search_12_filled,
            accentColor: Colors.indigo.shade600,
            title: "Buscar Cliente por #Cédula",
            subtitle: "Búsqueda directa por número de identificación",
            onTap: () {
              final clientRepo = context.read<ClientsRepository>();
              showSimpleSearchDialog(
                context,
                searchFuture: (value) {
                  if (value.isEmpty) {
                    return Future.error("La cédula no puede estar vacía");
                  }
                  return clientRepo.getClientByCardId(value.toUpperCase());
                },
                title: "Buscar Cliente por #Cédula",
                onResult: (value) {
                  showClientFullDetailsDialog(context, client: value);
                },
              );
            },
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.clientMap,
            child: MenuOptionCard(
              icon: Icons.map_rounded,
              accentColor: Colors.teal.shade600,
              title: "Mapa de Clientes",
              subtitle: "Geolocalización y distribución en mapa",
              onTap: () => context.pushNamed("client-map"),
            ),
          ),
          ShortcutAddableListTile(
            routeName: RouteNames.clientGroups,
            child: MenuOptionCard(
              icon: Icons.group_work_rounded,
              accentColor: Colors.purple.shade600,
              title: "Grupos de Clientes",
              subtitle: "Segmentación y tarifas preferenciales por grupo",
              onTap: () => context.pushNamed("client-groups"),
            ),
          ),
          MenuOptionCard(
            icon: Icons.picture_as_pdf,
            accentColor: Colors.red.shade600,
            title: "Exportar Clientes (PDF)",
            subtitle: "Descarga del catálogo en formato PDF",
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
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  DialogManager.showErrorDialog(context, e.toString());
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
