import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/cubit/write_exit_doc_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/mediator.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../view_controller.dart';
import 'mobile/inventory_exit_screen_mobile.dart';
import 'web/inventory_exit_screen_web.dart';

class InventoryExitScreen extends StatefulWidget {
  const InventoryExitScreen({super.key});

  @override
  State<InventoryExitScreen> createState() => _InventoryExitScreenState();
}

class _InventoryExitScreenState extends State<InventoryExitScreen> {
  late final InventoryExitViewController viewController;

  @override
  void initState() {
    super.initState();
    viewController = InventoryExitViewController();
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exitDocRepo = context.read<ExitDocsRepository>();

    return ShortcutContainer(
      child: BlocProvider(
        create: (context) => WriteExitDocCubit(exitDocRepo),
        child: InventoryExitMediator(
          viewController: viewController,
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
    final viewController = InventoryExitMediator.watch(context);

    return BlocListener<WriteExitDocCubit, WriteExitDocState>(
      listener: (context, state) async {
        if (state is WriteExitDocInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteExitDocError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteExitDocSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Salida de inventario guardada");
          if (!context.mounted) return;
          viewController.clear();
        }
      },
      child: _RootBody(key: viewController.formKey),
    );
  }
}

class _RootBody extends StatelessWidget {
  const _RootBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile();

    if (isMobile) return const InventoryExitScreenMobile();
    return const InventoryExitScreenWeb();
  }
}
