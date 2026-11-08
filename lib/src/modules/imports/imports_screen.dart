import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/imports/cubit/imports_cubit.dart';
import 'package:kardex_app_front/src/modules/imports/cubit/imports_state.dart';
import 'package:kardex_app_front/src/modules/imports/dialogs/import_confirmation_dialog.dart';
import 'package:kardex_app_front/src/modules/imports/dialogs/import_result_dialog.dart';
import 'package:kardex_app_front/src/modules/imports/tools/import_templates.dart';
import 'package:kardex_app_front/src/modules/imports/widgets/import_option_card.dart';
import 'package:kardex_app_front/src/tools/exports/csv_export_tool.dart';
import 'package:kardex_app_front/widgets/gates/role_permission_gate.dart';
import 'package:kardex_app_front/widgets/gates/root_user_gate.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

const int _maxFileSizeBytes = 10 * 1024 * 1024;

class ImportsScreen extends StatelessWidget {
  const ImportsScreen({super.key});

  static final accessName = Modules.settings.name;

  @override
  Widget build(BuildContext context) {
    return RootUserGate(
      fallback: Scaffold(
        appBar: AppBar(title: const Text("Importaciones CSV")),
        body: const Center(
          child: Text("Solo el usuario root puede acceder a las importaciones."),
        ),
      ),
      child: RolePermissionGate(
        permissions: const [Modules.settings],
        fallback: Scaffold(
          appBar: AppBar(title: const Text("Importaciones CSV")),
          body: const Center(
            child: Text("No tienes permisos para acceder a las importaciones."),
          ),
        ),
        child: BlocProvider(
          create: (context) => ImportsCubit(
            importsRepository: context.read<ImportsRepository>(),
            clientsRepository: context.read<ClientsRepository>(),
            suppliersRepository: context.read<SuppliersRepository>(),
          ),
          child: const _ImportsView(),
        ),
      ),
    );
  }
}

class _ImportsView extends StatelessWidget {
  const _ImportsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportsCubit, ImportsState>(
      builder: (context, state) {
        final loadingState = state is ImportsLoading ? state : null;

        return Scaffold(
          appBar: const MenuAppBar(title: "Importaciones CSV"),
          body: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 28),
                    children: [
                      const _HeaderBanner(),
                      const MenuSectionDivider(
                        title: "Inventario",
                        isFirst: true,
                      ),
                      _buildCard(context, ImportType.initialInventory, loadingState),
                      _buildCard(context, ImportType.inventory, loadingState),
                      const MenuSectionDivider(title: "Catálogos"),
                      _buildCard(context, ImportType.clients, loadingState),
                      _buildCard(context, ImportType.suppliers, loadingState),
                    ],
                  ),
                ),
              ),
              if (loadingState != null) _LoadingOverlay(type: loadingState.type),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    ImportType type,
    ImportsLoading? loadingState,
  ) {
    final config = _ImportCardConfig.forType(type);
    final template = ImportTemplates.forType(type);
    final isBusy = loadingState?.type == type;

    return ImportOptionCard(
      title: config.title,
      description: config.description,
      columns: template.columns,
      icon: config.icon,
      accentColor: config.accentColor,
      badgeLabel: config.badgeLabel,
      warning: config.warning,
      isBusy: isBusy,
      onImport: () => _pickAndImport(context, type),
      onDownloadTemplate: () => _downloadTemplate(context, type),
    );
  }

  Future<void> _pickAndImport(BuildContext context, ImportType type) async {
    final cubit = context.read<ImportsCubit>();
    if (cubit.state is ImportsLoading) {
      return;
    }

    final authCubit = getIt<AuthCubit>();
    final currentBranch = authCubit.currentBranch;
    final requiresBranch = type != ImportType.suppliers;

    if (requiresBranch && currentBranch == null) {
      await DialogManager.showErrorDialog(
        context,
        "Selecciona una sucursal antes de realizar una importación.",
      );
      return;
    }

    final config = _ImportCardConfig.forType(type);
    final branchId = authCubit.currentBranchId;
    final branchName = requiresBranch ? currentBranch?.name : null;

    FilePickerResult? pickerResult;

    try {
      pickerResult = await FilePicker.pickFiles(
        dialogTitle: "Seleccionar ${config.title} (CSV)",
        type: FileType.custom,
        allowedExtensions: const ["csv"],
        withData: true,
      );
    } catch (error) {
      if (!context.mounted) return;
      await DialogManager.showErrorDialog(
        context,
        "No se pudo abrir el selector de archivos: $error",
      );
      return;
    }

    if (pickerResult == null || pickerResult.files.isEmpty) {
      return;
    }

    final file = pickerResult.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      if (!context.mounted) return;
      await DialogManager.showErrorDialog(
        context,
        "No se pudo leer el archivo seleccionado.",
      );
      return;
    }

    if (file.size > _maxFileSizeBytes) {
      if (!context.mounted) return;
      await DialogManager.showErrorDialog(
        context,
        "El archivo supera el tamaño máximo permitido de 10 MB.",
      );
      return;
    }

    if (!file.name.toLowerCase().endsWith(".csv")) {
      if (!context.mounted) return;
      await DialogManager.showErrorDialog(
        context,
        "El archivo debe ser de formato .csv.",
      );
      return;
    }

    if (!context.mounted) return;

    final confirmed = await ImportConfirmationDialog.show(
      context,
      title: config.title,
      fileName: file.name,
      fileSizeBytes: file.size,
      branchName: branchName,
      icon: config.icon,
      accentColor: config.accentColor,
      warning: config.warning,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final result = await cubit.importFile(
      type: type,
      bytes: bytes,
      fileName: file.name,
      branchId: branchId,
    );

    if (!context.mounted) {
      return;
    }

    if (result != null) {
      await ImportResultDialog.showSuccess(
        context,
        title: config.title,
        result: result,
      );
      return;
    }

    final state = cubit.state;
    final message = state is ImportsError ? state.message : "No se pudo completar la importación.";

    await ImportResultDialog.showError(context, message: message);
  }

  Future<void> _downloadTemplate(BuildContext context, ImportType type) async {
    final template = ImportTemplates.forType(type);

    try {
      final savedPath = await CsvExportTool.saveCsvContent(
        fileName: template.fileName,
        content: template.content,
      );

      if (!context.mounted || savedPath == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Plantilla ${template.fileName} descargada."),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      await DialogManager.showErrorDialog(
        context,
        "No se pudo descargar la plantilla: $error",
      );
    }
  }
}

class _ImportCardConfig {
  const _ImportCardConfig({
    required this.title,
    required this.description,
    required this.badgeLabel,
    required this.icon,
    required this.accentColor,
    required this.warning,
  });

  final String title;
  final String description;
  final String badgeLabel;
  final IconData icon;
  final Color accentColor;
  final String? warning;

  static _ImportCardConfig forType(ImportType type) {
    return switch (type) {
      ImportType.initialInventory => const _ImportCardConfig(
        title: "Inventario inicial",
        description:
            "Carga productos con su stock, costo y precios iniciales. "
            "Ideal para aperturar una sucursal.",
        badgeLabel: "Una vez por sucursal",
        icon: Icons.inventory_2_rounded,
        accentColor: AppThemeTokens.warning,
        warning:
            "Solo debe usarse en una sucursal sin inventario. Crea productos, "
            "stock y el documento de inventario inicial; no se puede repetir.",
      ),
      ImportType.inventory => const _ImportCardConfig(
        title: "Importar inventario",
        description: "Carga productos y existencias adicionales en la sucursal activa.",
        badgeLabel: "Agrega stock",
        icon: Icons.add_box_rounded,
        accentColor: AppThemeTokens.teal,
        warning:
            "Crea productos nuevos y carga existencias. No actualiza productos "
            "existentes ni detecta códigos duplicados.",
      ),
      ImportType.clients => const _ImportCardConfig(
        title: "Importar clientes",
        description: "Carga el directorio de clientes, límites de crédito y saldos iniciales.",
        badgeLabel: "Catálogo",
        icon: Icons.people_alt_rounded,
        accentColor: AppThemeTokens.info,
        warning:
            "Crea clientes nuevos. Verifica que las cédulas no estén duplicadas "
            "antes de importar.",
      ),
      ImportType.suppliers => const _ImportCardConfig(
        title: "Importar proveedores",
        description: "Carga el directorio de proveedores con sus datos de contacto.",
        badgeLabel: "Catálogo",
        icon: Icons.local_shipping_rounded,
        accentColor: AppThemeTokens.indigo,
        warning:
            "Crea proveedores nuevos. Verifica que no estén duplicados antes "
            "de importar.",
      ),
    };
  }
}

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppThemeTokens.borderRadiusLg,
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: AppThemeTokens.borderRadiusMd,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Carga masiva desde CSV",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Importa inventario, clientes y proveedores. Usa las "
                  "plantillas para asegurar el formato correcto.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _HeaderChip(icon: Icons.code_rounded, label: "UTF-8"),
                    _HeaderChip(
                      icon: Icons.table_chart_rounded,
                      label: "CSV",
                    ),
                    _HeaderChip(
                      icon: Icons.data_usage_rounded,
                      label: "Máx. 10 MB",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: AppThemeTokens.borderRadiusFull,
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.type});

  final ImportType type;

  @override
  Widget build(BuildContext context) {
    final title = _ImportCardConfig.forType(type).title;

    return Positioned.fill(
      child: Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.18),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppThemeTokens.borderRadiusLg,
                boxShadow: AppThemeTokens.dialogShadow(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Importando $title...",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "No cierres esta pantalla",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
