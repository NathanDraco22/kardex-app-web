import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/src/domain/models/common/exit_items.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_exits_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/cubit/write_adjust_exit_cubit.dart';

import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import 'mediator.dart';

part 'web/adjust_exit_web_screen.dart';
part 'web/sections/header_section.dart';
part 'web/sections/content_section.dart';

part 'mobile/adjust_exit_mobile_screen.dart';

class RebuildAdjustExitScreenNotification extends Notification {}

class AdjustExitScreen extends StatefulWidget {
  final AdjustExitType type;
  const AdjustExitScreen({super.key, required this.type});

  @override
  State<AdjustExitScreen> createState() => _AdjustExitScreenState();
}

class _AdjustExitScreenState extends State<AdjustExitScreen> {
  late AdjustExitNotifier notifier;
  bool rebuildScreen = false;

  @override
  void initState() {
    notifier = AdjustExitNotifier();
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

    final repo = context.read<AdjustExitsRepository>();

    return NotificationListener<RebuildAdjustExitScreenNotification>(
      onNotification: (notification) {
        notifier = AdjustExitNotifier();
        rebuildScreen = true;
        setState(() {});
        return true;
      },
      child: BlocProvider(
        create: (context) => WriteAdjustExitCubit(repository: repo),
        child: AdjustExitMediator(
          type: widget.type,
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
    return BlocListener<WriteAdjustExitCubit, WriteAdjustExitState>(
      listener: (context, state) async {
        if (state is WriteAdjustExitLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is WriteAdjustExitFailure) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }
        if (state is WriteAdjustExitSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Salida de inventario guardada correctamente");
          if (!context.mounted) return;
          RebuildAdjustExitScreenNotification().dispatch(context);
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
      return const AdjustExitMobileScreen();
    }
    return const AdjustExitWebScreen();
  }
}
