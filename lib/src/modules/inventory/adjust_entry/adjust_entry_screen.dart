import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

import 'package:kardex_app_front/src/domain/models/common/entry_items.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/adjust_entry/adjust_entry_model.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_entries_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_entry/cubit/write_adjust_entry_cubit.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import 'mediator.dart';

part 'web/adjust_entry_web_screen.dart';
part 'web/sections/header_section.dart';
part 'web/sections/content_section.dart';

part 'mobile/adjust_entry_mobile_screen.dart';

// Notification to rebuild the screen (clear data)
class RebuildAdjustEntryScreenNotification extends Notification {}

class AdjustEntryScreen extends StatefulWidget {
  const AdjustEntryScreen({super.key});

  @override
  State<AdjustEntryScreen> createState() => _AdjustEntryScreenState();
}

class _AdjustEntryScreenState extends State<AdjustEntryScreen> {
  late AdjustEntryNotifier notifier;
  bool rebuildScreen = false;

  @override
  void initState() {
    notifier = AdjustEntryNotifier();
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

    final repo = context.read<AdjustEntriesRepository>();

    return NotificationListener<RebuildAdjustEntryScreenNotification>(
      onNotification: (notification) {
        notifier = AdjustEntryNotifier();
        rebuildScreen = true;
        setState(() {});
        return true;
      },
      child: BlocProvider(
        create: (context) => WriteAdjustEntryCubit(repository: repo),
        child: AdjustEntryMediator(
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
    return BlocListener<WriteAdjustEntryCubit, WriteAdjustEntryState>(
      listener: (context, state) async {
        if (state is WriteAdjustEntryLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteAdjustEntryFailure) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }
        if (state is WriteAdjustEntrySuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Ajuste de inventario guardado correctamente");
          if (!context.mounted) return;
          RebuildAdjustEntryScreenNotification().dispatch(context);
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
    if (context.isMobile()) {
      return const AdjustEntryMobileScreen();
    }
    return const AdjustEntryWebScreen();
  }
}
