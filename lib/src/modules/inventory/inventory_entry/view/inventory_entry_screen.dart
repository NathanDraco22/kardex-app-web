import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/entry_history/entry_history.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_entry/cubit/write_entry_doc_cubit.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

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
  late InventoryEntryNotifier notifier;

  bool rebuildScreen = false;

  @override
  void initState() {
    notifier = InventoryEntryNotifier();
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

    final entryDocRepo = context.read<EntryDocsRepository>();
    return NotificationListener<RebuildScreeenNotification>(
      onNotification: (notification) {
        notifier = InventoryEntryNotifier();
        rebuildScreen = true;
        setState(() {});
        return true;
      },

      child: BlocProvider(
        create: (context) => WriteEntryDocCubit(entryDocRepo),
        child: InventoryEntryMediator(
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

    if (isMobile) return const InventoryEntryMobileScreen();

    return const InventoryEntryScreenWeb();
  }
}
