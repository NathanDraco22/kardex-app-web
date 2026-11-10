import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/local_printer_settings_dialog.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/gates/root_user_gate.dart';
import 'package:kardex_app_front/widgets/shortcut_addable_list_tile.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final accessName = Modules.settings.name;

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
        title: const Text("Configuraciones"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final authUser = getIt<AuthCubit>().user;
    final bool isRootOrAdmin =
        authUser != null &&
        (authUser.id == 'root' || authUser.username.toLowerCase() == 'root' || authUser.role == 'Admin');
    final bool showDangerZone = context.isDesktop() && isRootOrAdmin;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            ShortcutAddableListTile(
              routeName: RouteNames.users,
              child: MenuOptionCard(
                icon: Icons.person,
                accentColor: Colors.blue.shade600,
                title: "Usuarios",
                subtitle: "Cuentas de usuario, roles y permisos",
                onTap: () => context.pushNamed("users"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.branches,
              child: MenuOptionCard(
                icon: Icons.other_houses,
                accentColor: Colors.teal.shade600,
                title: "Ramas / Sucursales",
                subtitle: "Gestión de sedes, almacenes y parámetros",
                onTap: () => context.pushNamed("branches"),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.integrations,
              child: MenuOptionCard(
                icon: Icons.integration_instructions,
                accentColor: Colors.indigo.shade600,
                title: "Integraciones",
                subtitle: "Servicios periféricos y conexiones",
                onTap: () => context.pushNamed("integrations"),
              ),
            ),
            RootUserGate(
              child: ShortcutAddableListTile(
                routeName: RouteNames.imports,
                child: MenuOptionCard(
                  icon: Icons.upload_file_rounded,
                  accentColor: Colors.orange.shade700,
                  title: "Importaciones CSV",
                  subtitle: "Carga masiva de inventario, clientes y proveedores",
                  onTap: () => context.pushNamed(RouteNames.imports),
                ),
              ),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.apiKeys,
              child: MenuOptionCard(
                icon: Icons.key,
                accentColor: Colors.amber.shade700,
                title: "Llaves de API (Neptuno)",
                subtitle: "Credenciales de comunicación y sincronización",
                onTap: () => context.pushNamed(RouteNames.apiKeys),
              ),
            ),
            MenuOptionCard(
              icon: Icons.print,
              accentColor: Colors.blueGrey.shade700,
              title: "Configuración de Impresora Local",
              subtitle: "Configuración de tickets e impresión térmica",
              onTap: () => showLocalPrinterSettingsDialog(context),
            ),
            ShortcutAddableListTile(
              routeName: RouteNames.appSettings,
              child: MenuOptionCard(
                icon: Icons.tune_rounded,
                accentColor: Colors.deepPurple.shade600,
                title: "Configuraciones del Sistema",
                subtitle: "Margen de ganancia, vencimientos, órdenes y reglas globales",
                onTap: () => context.pushNamed("app-settings"),
              ),
            ),
            if (showDangerZone) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      "Zona de Peligro",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const _DangerZoneCard(),
            ],
          ],
        ),
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      builder: (context, state) {
        final currentBranch = getIt<AuthCubit>().currentBranch;
        final branchName = currentBranch?.name ?? "Sin sucursal seleccionada";

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restart_alt_rounded,
                  color: Colors.red.shade800,
                  size: 26,
                ),
              ),
              title: const Text(
                "Reiniciar Inventario a 0",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF991B1B),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Genera un ajuste de salida de auditoría que vacía las existencias físicas de la sucursal ($branchName). Irreversible.",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.red.shade900.withValues(alpha: 0.85),
                  ),
                ),
              ),
              trailing: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () async {
                  BranchInDb? target = currentBranch;
                  if (target == null) {
                    final allBranches = context.read<BranchesRepository>().branches;
                    if (allBranches.isNotEmpty) {
                      final selected = await showBranchSelectionDialog(
                        context,
                        allBranches,
                        currentBranchId: getIt<AuthCubit>().currentBranchId,
                      );
                      if (selected == null) return;
                      target = selected;
                    }
                  }

                  if (target == null) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No hay sucursales disponibles."),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  if (!context.mounted) return;
                  final result = await showResetInventoryDangerDialog(
                    context,
                    branch: target,
                  );
                  if (result != null && context.mounted) {
                    _showResetSuccessDialog(context, result);
                  }
                },
                child: const Text(
                  "Reiniciar a 0",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetSuccessDialog(BuildContext context, ResetInventoryResult result) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.teal,
            size: 44,
          ),
          title: const Text(
            "Inventario Reiniciado",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 14),
              if (result.docNumber.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    "• Comprobante de Ajuste: ${result.docNumber}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              Text(
                "• Productos ajustados: ${result.adjustedProductsCount}",
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                "• Unidades descargadas: ${result.totalQuantityRemoved}",
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Entendido"),
            ),
          ],
        );
      },
    );
  }
}
