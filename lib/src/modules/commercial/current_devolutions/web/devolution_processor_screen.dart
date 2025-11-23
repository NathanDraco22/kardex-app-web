import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/cubit/read_devolution_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/cubit/write_devolution_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/modals/cancel_devolution_modal.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/modals/confirm_devolution_modal.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';

Future<DevolutionInDb?> showDevolutionProcessorDialog(BuildContext context, DevolutionInDb devolution) async {
  final readCubit = context.read<ReadDevolutionCubit>();
  return await Navigator.push<DevolutionInDb?>(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: readCubit,
        child: DevolutionProcessorScreen(devolution: devolution),
      ),
    ),
  );
}

class DevolutionProcessorMediator extends InheritedWidget {
  const DevolutionProcessorMediator({super.key, required super.child, required this.devolution});

  final DevolutionInDb devolution;

  static DevolutionProcessorMediator of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DevolutionProcessorMediator>()!;
  }

  @override
  bool updateShouldNotify(DevolutionProcessorMediator oldWidget) {
    return false;
  }
}

class DevolutionProcessorScreen extends StatelessWidget {
  const DevolutionProcessorScreen({super.key, required this.devolution});

  final DevolutionInDb devolution;

  @override
  Widget build(BuildContext context) {
    final devolutionRepo = context.read<DevolutionsRepository>();
    return DevolutionProcessorMediator(
      devolution: devolution,
      child: BlocProvider(
        create: (context) => WriteDevolutionCubit(
          devolutionsRepository: devolutionRepo,
        ),
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final colorsMap = {
      DevolutionStatus.open: Colors.blue.shade400,
      DevolutionStatus.confirmed: Colors.green.shade400,
      DevolutionStatus.cancelled: Colors.red.shade400,
      DevolutionStatus.applied: Colors.grey.shade700,
    };
    final tagMap = {
      DevolutionStatus.open: "Abierta",
      DevolutionStatus.confirmed: "Confirmada",
      DevolutionStatus.cancelled: "Cancelada",
      DevolutionStatus.applied: "Aplicada",
    };
    final devolution = DevolutionProcessorMediator.of(context).devolution;
    final writeCubit = context.read<WriteDevolutionCubit>();
    return BlocListener<WriteDevolutionCubit, WriteDevolutionState>(
      listener: (context, state) async {
        if (state is WriteDevolutionInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteDevolutionError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteDevolutionSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          final resultDevolution = state.devolution;
          String message = "Devolución ${resultDevolution.status.name} con éxito";
          await DialogManager.showInfoDialog(context, message);
          if (!context.mounted) return;
          final readCubit = context.read<ReadDevolutionCubit>();
          await readCubit.markDevolutionUpdated(state.devolution);
          if (!context.mounted) return;
          await showDevolutionViewerDialog(context, devolution);
          if (!context.mounted) return;
          Navigator.pop(context, state.devolution);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Procesar Devolución")),
        body: const _Body(),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Builder(
            builder: (context) {
              if (devolution.status != DevolutionStatus.open) {
                final textColor = colorsMap[devolution.status] ?? Colors.black;
                return Center(
                  child: Text(
                    tagMap[devolution.status] ?? "",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                    ),
                    onPressed: () async {
                      final res = await showCancelDevolutionModal(context, devolution);
                      if (res != true) return;
                      writeCubit.cancelDevolution(devolution.id);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade300,
                    ),
                    onPressed: () async {
                      final res = await showConfirmDevolutionModal(context, devolution);
                      if (res != true) return;
                      writeCubit.confirmDevolution(devolution);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Confirmar"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final mediator = DevolutionProcessorMediator.of(context);
    final devolution = mediator.devolution;
    final returnedItems = devolution.returnedItems;
    final totalFormatted = NumberFormatter.convertToMoneyLike(devolution.total);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Devolución: #${devolution.docNumber}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            "Factura: #${devolution.originalInvoiceDocNumber}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          TextButton(
                            onPressed: () {
                              showInvoiceViewerDialogFromId(context, devolution.originalInvoiceId);
                            },
                            child: const Text("Ver Factura"),
                          ),
                        ],
                      ),
                      Text(
                        DateTimeTool.formatddMMyy(devolution.createdAt),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        devolution.clientInfo.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Descripción: ${devolution.description}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Total: $totalFormatted",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Detalle de Devolución:",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: returnedItems.length,
                            itemBuilder: (context, index) {
                              final item = returnedItems[index];
                              return ListTile(
                                leading: Text("${item.quantity} x"),
                                title: Text(item.product.name),
                                subtitle: Text(item.product.brandName),
                                trailing: Text(NumberFormatter.convertToMoneyLike(item.total)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
