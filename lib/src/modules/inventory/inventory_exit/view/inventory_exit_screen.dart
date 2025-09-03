import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/cubit/write_exit_doc_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/mediator.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import 'mobile/inventory_exit_screen_mobile.dart';
import 'web/inventory_exit_screen_web.dart';

class InventoryExitScreen extends StatefulWidget {
  const InventoryExitScreen({super.key});

  @override
  State<InventoryExitScreen> createState() => _InventoryExitScreenState();
}

class _InventoryExitScreenState extends State<InventoryExitScreen> {
  late InventoryExitNotifier notifier;

  bool rebuildScreen = false;

  @override
  void initState() {
    notifier = InventoryExitNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (rebuildScreen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        rebuildScreen = false;
        setState(() {});
      });
      return const EmptyScaffold();
    }

    final exitDocRepo = context.read<ExitDocsRepository>();
    return NotificationListener<RebuildScreeenNotification>(
      onNotification: (notification) {
        notifier = InventoryExitNotifier();
        rebuildScreen = true;
        setState(() {});
        return true;
      },
      child: BlocProvider(
        create: (context) => WriteExitDocCubit(exitDocRepo),
        child: InventoryExitMediator(
          notifier: notifier,
          child: const _RootScaffold(),
        ),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteExitDocCubit, WriteExitDocState>(
      listener: (context, state) {
        if (state is WriteExitDocInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteExitDocError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteExitDocSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showInfoDialog(context, "Salida de inventario guardada");
          if (!context.mounted) return;
          RebuildScreeenNotification().dispatch(context);
        }
      },
      child: const _RootBody(),
    );
  }
}

class _RootBody extends StatelessWidget {
  const _RootBody();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile();

    if (isMobile) return const InventoryExitScreenMobile();
    return const InventoryExitScreenWeb();
  }
}
