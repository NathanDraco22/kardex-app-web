import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/branch_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';

import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import '../mediator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/transfer_item.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class RebuildTransferScreenNotification extends Notification {}

class CreateTransferScreenWeb extends StatelessWidget {
  const CreateTransferScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteTransferCubit, WriteTransferState>(
      listener: (context, state) {
        if (state is WriteTransferLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        } else {
          LoadingDialogManager.closeLoadingDialog(context);
        }

        if (state is WriteTransferSuccess) {
          DialogManager.showInfoDialog(context, "Transferencia ${state.transfer.docNumber} guardada");
          if (!context.mounted) return;
          RebuildTransferScreenNotification().dispatch(context);
        }

        if (state is WriteTransferFailure) {
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => saveTransfer(context),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Nueva Transferencia"),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: const _Body(),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: _HeaderSection(),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
