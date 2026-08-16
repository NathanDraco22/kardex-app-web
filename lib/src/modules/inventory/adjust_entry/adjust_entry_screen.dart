import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';

import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/inventory/adjust_entry/cubit/write_adjust_entry_cubit.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';

import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';

import 'mediator.dart';
import 'view_controller.dart';

part 'web/adjust_entry_web_screen.dart';
part 'web/sections/header_section.dart';
part 'web/sections/content_section.dart';

part 'mobile/adjust_entry_mobile_screen.dart';

class AdjustEntryScreen extends StatefulWidget {
  const AdjustEntryScreen({super.key});

  @override
  State<AdjustEntryScreen> createState() => _AdjustEntryScreenState();
}

class _AdjustEntryScreenState extends State<AdjustEntryScreen> {
  late final AdjustEntryViewController viewController;

  @override
  void initState() {
    super.initState();
    viewController = AdjustEntryViewController();
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AdjustEntriesRepository>();

    return BlocProvider(
      create: (context) => WriteAdjustEntryCubit(repository: repo),
      child: AdjustEntryMediator(
        viewController: viewController,
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustEntryMediator.watch(context);

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
      return const AdjustEntryMobileScreen();
    }
    return const AdjustEntryWebScreen();
  }
}
