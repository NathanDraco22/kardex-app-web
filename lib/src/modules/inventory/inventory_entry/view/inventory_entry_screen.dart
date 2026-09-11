import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/cubit/write_entry_doc_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';

import '../view_controller.dart';
import 'mediator.dart';
import 'mobile/widgets/appbar_menu.dart';

part 'web/inventory_entry_screen_web.dart';
part 'web/sections/content_section.dart';
part 'web/sections/header_section.dart';

part 'mobile/inventory_entry_mobile_screen.dart';

class InventoryEntryScreen extends StatefulWidget {
  const InventoryEntryScreen({super.key});

  @override
  State<InventoryEntryScreen> createState() => _InventoryEntryScreenState();
}

class _InventoryEntryScreenState extends State<InventoryEntryScreen> {
  late final InventoryEntryViewController viewController;

  @override
  void initState() {
    super.initState();
    viewController = InventoryEntryViewController();
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryDocRepo = context.read<EntryDocsRepository>();

    return ShortcutContainer(
      child: BlocProvider(
        create: (context) => WriteEntryDocCubit(entryDocRepo, useKardex: false),
        child: InventoryEntryMediator(
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
    final viewController = InventoryEntryMediator.watch(context);

    return BlocListener<WriteEntryDocCubit, WriteEntryDocState>(
      listener: (context, state) async {
        if (state is WriteEntryDocInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteEntryDocError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteEntryDocSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Entrada de inventario guardada");
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

    if (isMobile) return const InventoryEntryMobileScreen();

    return const InventoryEntryScreenWeb();
  }
}
