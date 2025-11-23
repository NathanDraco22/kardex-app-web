import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/models/invoice/invoice_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/cubits/write_devolution_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/modals/confirm_devolution_modal.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/devolution_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';

part 'confirmation_sections/content_section.dart';
part 'confirmation_sections/header_section.dart';

class DevolutionConfirmationScreen extends StatelessWidget {
  const DevolutionConfirmationScreen({
    super.key,
    required this.invoice,
    required this.selectedItems,
    required this.description,
  });

  final InvoiceInDb invoice;
  final List<SaleItem> selectedItems;
  final String description;

  @override
  Widget build(BuildContext context) {
    final devolutionsRepo = context.read<DevolutionsRepository>();
    return BlocProvider(
      create: (context) => WriteDevolutionCubit(devolutionsRepository: devolutionsRepo),
      child: _RootScaffold(
        invoice: invoice,
        selectedItems: selectedItems,
        description: description,
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({
    required this.invoice,
    required this.selectedItems,
    required this.description,
  });

  final InvoiceInDb invoice;
  final List<SaleItem> selectedItems;
  final String description;

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<WriteDevolutionCubit>();
    final authCubit = context.read<AuthCubit>();
    final authState = authCubit.state;

    if (authState is! Authenticated) {
      return const Center(
        child: SizedBox.shrink(),
      );
    }

    final user = authState.session.user;

    return BlocListener(
      bloc: writeCubit,
      listener: (context, state) async {
        if (state is WriteDevolutionInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteDevolutionError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteDevolutionSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Devolución guardada con éxito");
          if (!context.mounted) return;
          await showDevolutionViewerDialog(context, state.devolution);
          if (!context.mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Confirmar"),
        ),
        body: _Body(
          invoice: invoice,
          selectedItems: selectedItems,
          description: description,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.check),
          label: const Text("Finalizar Devolución"),
          onPressed: () async {
            final total = selectedItems.fold<int>(
              0,
              (previousValue, element) => previousValue + element.total,
            );

            final totalCost = selectedItems.fold<int>(
              0,
              (previousValue, element) => previousValue + (element.cost * element.quantity),
            );

            final userInfo = UserInfo(id: user.id, name: user.username);

            final createDevolution = CreateDevolution(
              branchId: invoice.branchId,
              clientId: invoice.clientId,
              clientInfo: invoice.clientInfo,
              originalInvoiceId: invoice.id,
              originalInvoiceDocNumber: invoice.docNumber,
              returnedItems: selectedItems,
              description: description,
              totalCost: totalCost,
              total: total,
              createdBy: userInfo,
            );

            final res = await showConfirmationDevolutionModal(context, createDevolution);

            if (res != true) return;

            writeCubit.createNewDevolution(createDevolution);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.invoice,
    required this.selectedItems,
    required this.description,
  });

  final InvoiceInDb invoice;
  final List<SaleItem> selectedItems;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(
                invoice: invoice,
                description: description,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _ContentSection(items: selectedItems),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
