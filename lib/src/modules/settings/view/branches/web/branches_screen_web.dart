part of "../branches_screen.dart";

class _BranchesScreenWeb extends StatelessWidget {
  const _BranchesScreenWeb();

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
      appBar: AppBar(
        title: const Text("Ramas/Sucursales"),
      ),
      body: BlocBuilder<ReadBranchCubit, ReadBranchState>(
        builder: (context, state) {
          if (state is ReadBranchLoading || state is ReadBranchInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is BranchReadError) {
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

  Future<void> _uploadExistingImageToCloud(BuildContext context, BranchInDb branch) async {
    final imageBytes = branch.image;
    if (imageBytes == null || imageBytes.isEmpty) {
      DialogManager.showInfoDialog(context, "Esta sucursal no tiene imagen local para subir.");
      return;
    }

    final confirmed = await DialogManager.slideToConfirmActionDialog(
      context,
      "¿Deseas subir el logo de '${branch.name}' a la nube?",
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    LoadingDialogManager.showLoadingDialog(context);
    try {
      final fileName = "branch_${branch.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final uploadedUrl = await ImageUploader.uploadImage(
        bytes: imageBytes,
        fileName: fileName,
      );

      if (!context.mounted) return;

      final updateBranch = UpdateBranch(

        imageUrl: uploadedUrl,

        image: "",

      );
      final branchRepo = context.read<BranchesRepository>();
      await branchRepo.updateBranchById(branch.id, updateBranch);

      if (!context.mounted) return;
      LoadingDialogManager.closeLoadingDialog(context);

      if (!context.mounted) return;
      await context.read<ReadBranchCubit>().refreshBranch();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Logo de '${branch.name}' subido con éxito a la nube!"),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        LoadingDialogManager.closeLoadingDialog(context);
        DialogManager.showErrorDialog(context, "Error al subir imagen a la nube: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadBranchCubit>();
    final state = cubit.state as ReadBranchSuccess;
    final branches = state.branches;

    return BlocBuilder<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(
            child: Text("No autenticado"),
          );
        }

        final user = authState.session.user;
        final isMultiBranch = authState.servin.isMultiBranch;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Las Ramas/Sucursales no pueden ser eliminadas",
                      style: TextStyle(color: Colors.amber.shade600, letterSpacing: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Builder(
                  builder: (context) {
                    if (!isMultiBranch || user.role != "Admin") {
                      return const SizedBox.shrink();
                    }
                    if (user.id != "root") {
                      return const SizedBox.shrink();
                    }

                    return Row(
                      children: [
                        const Spacer(),
                        SizedBox(
                          height: 40,
                          child: PrimaryMenuButton(
                            onPressed: () async {
                              final res = await showCreateBranchPriceDialog(context);
                              if (res == null) return;
                              if (!context.mounted) return;
                              await context.read<ReadBranchCubit>().refreshBranch();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text("Agregar Nueva Rama/Sucursal"),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                Card(
                  child: Column(
                    children: [
                      ...List.generate(
                        branches.length,
                        (index) {
                          final branch = branches[index];
                          final hasCloudImage = branch.imageUrl != null && branch.imageUrl!.trim().isNotEmpty;
                          final hasLocalBase64 = branch.image != null && branch.image!.isNotEmpty;
                          final canMigrateToCloud = !hasCloudImage && hasLocalBase64;

                          return ListTile(
                            leading: _BranchAvatar(branch: branch),
                            title: Row(
                              children: [
                                Text(
                                  branch.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                if (branch.isCommerce)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "Comercio",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "No comercial",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              branch.description.isNotEmpty ? branch.description : "Sin descripción",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasCloudImage)
                                  const Tooltip(
                                    message: "Logo sincronizado en la nube",
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Icon(Icons.cloud_done_rounded, color: Colors.green, size: 22),
                                    ),
                                  ),
                                if (canMigrateToCloud)
                                  Tooltip(
                                    message: "Subir imagen existente a la nube",
                                    child: IconButton(
                                      icon: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                                      onPressed: () => _uploadExistingImageToCloud(context, branch),
                                    ),
                                  ),
                                IconButton(
                                  onPressed: () async {
                                    final res = await showCreateBranchPriceDialog(
                                      context,
                                      branch: branch,
                                    );
                                    if (res == null) return;
                                    if (!context.mounted) return;
                                    await context.read<ReadBranchCubit>().refreshBranch();
                                  },
                                  icon: const Icon(Icons.edit),
                                  tooltip: "Editar sucursal",
                                ),
                                  IconButton(
                                    onPressed: () async {
                                      final result = await showResetInventoryDangerDialog(
                                        context,
                                        branch: branch,
                                      );
                                      if (result != null && context.mounted) {
                                        showDialog<void>(
                                          context: context,
                                          builder: (dCtx) => AlertDialog(
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
                                                const SizedBox(height: 12),
                                                if (result.docNumber.isNotEmpty)
                                                  Text(
                                                    "• Comprobante: ${result.docNumber}",
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold, fontSize: 13),
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
                                                onPressed: () => Navigator.of(dCtx).pop(),
                                                child: const Text("Entendido"),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(Icons.restart_alt_rounded, color: Colors.red.shade700),
                                    tooltip: "Zona de Peligro: Reiniciar inventario a 0 de ${branch.name}",
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BranchAvatar extends StatelessWidget {
  const _BranchAvatar({required this.branch});

  final BranchInDb branch;

  @override
  Widget build(BuildContext context) {
    final hasCloudImage = branch.imageUrl != null && branch.imageUrl!.trim().isNotEmpty;
    final hasLocalBase64 = branch.image != null && branch.image!.isNotEmpty;

    ImageProvider? imageProvider;
    if (hasCloudImage) {
      imageProvider = CachedNetworkImageProvider(
        branch.imageUrl!,
        cacheManager: AppImageCacheManager.instance,
      );
    } else if (hasLocalBase64) {
      imageProvider = MemoryImage(branch.image!);
    }

    if (imageProvider != null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: imageProvider,
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: branch.isCommerce
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : Colors.grey.shade200,
      child: Icon(
        branch.isCommerce ? Icons.storefront : Icons.warehouse_outlined,
        color: branch.isCommerce ? Theme.of(context).primaryColor : Colors.grey,
        size: 20,
      ),
    );
  }
}
