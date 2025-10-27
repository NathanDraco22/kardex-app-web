import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/inventory/expiration_logs/cubit/read_expiration_log_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/expiration_logs/modals/create_expiration_log.dart';
import 'package:kardex_app_front/src/modules/inventory/expiration_logs/modals/expiration_log_viewer.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

import '../cubit/write_expiration_log_cubit.dart';

class ExpirationLogsScreenWeb extends StatelessWidget {
  const ExpirationLogsScreenWeb({super.key});

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
        title: const Text("Bitacora de Vencimientos"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showExpirationLogCreationScreen(context);
        },
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadExpirationLogCubit>();
    final state = readCubit.state;

    if (state is ReadExpirationLogLoading || state is ReadExpirationLogInitial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ReadExpirationLogError) {
      return Center(
        child: Text(state.message),
      );
    }

    state as ReadExpirationLogSuccess;

    final logs = state.logs;

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final currentLog = logs[index];
        final currentProduct = currentLog.product;

        final days = currentLog.expirationDate.difference(DateTime.now()).inDays;

        Color? color;

        if (days <= 100) {
          color = Colors.amber.shade200;
        }
        if (days <= 30) {
          color = Colors.red.shade200;
        }

        if (days <= 0) {
          color = Colors.red.shade300;
        }

        return ListTile(
          onTap: () {
            showExpirationLogViewerDialog(context, log: currentLog);
          },
          tileColor: color,
          minLeadingWidth: 50,
          leading: Text(
            DateTimeTool.formatMMyy(currentLog.expirationDate),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          title: Text(currentLog.product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Row(
            spacing: 4,
            children: [
              Text(currentProduct.brandName, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(currentProduct.unitName, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          trailing: IconButton(
            onPressed: () async {
              final isConfirm = await DialogManager.confirmActionDialog(
                context,
                "Eliminar ${currentLog.product.name} de la bitácora de vencimientos?",
              );
              if (isConfirm != true) return;
              if (!context.mounted) return;
              context.read<WriteExpirationLogCubit>().deleteExpirationLog(currentLog.id);
              context.read<ReadExpirationLogCubit>().removeLog(currentLog);
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
