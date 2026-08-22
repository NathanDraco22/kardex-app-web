import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';

import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_exit/cubit/write_adjust_exit_cubit.dart';

import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';

import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';

import 'mediator.dart';
import 'view_controller.dart';

part 'web/adjust_exit_web_screen.dart';
part 'web/sections/header_section.dart';
part 'web/sections/content_section.dart';

part 'mobile/adjust_exit_mobile_screen.dart';

class AdjustExitScreen extends StatefulWidget {
  final AdjustExitType type;
  const AdjustExitScreen({super.key, required this.type});

  @override
  State<AdjustExitScreen> createState() => _AdjustExitScreenState();
}

class _AdjustExitScreenState extends State<AdjustExitScreen> {
  late final AdjustExitViewController viewController;

  @override
  void initState() {
    super.initState();
    viewController = AdjustExitViewController(type: widget.type);
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AdjustExitsRepository>();

    return ShortcutContainer(
      child: BlocProvider(
        create: (context) => WriteAdjustExitCubit(repository: repo),
        child: AdjustExitMediator(
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
    final viewController = AdjustExitMediator.watch(context);

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
    if (context.isMobile()) {
      return const AdjustExitMobileScreen();
    }
    return const AdjustExitWebScreen();
  }
}
