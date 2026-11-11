import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/adjustment_request_form_actions.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/adjustment_request_mediator.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_editor_cards.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_totals_bar.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestFormMobileScreen extends StatelessWidget {
  const AdjustmentRequestFormMobileScreen({
    super.key,
    required this.editingRequest,
    required this.isEditing,
  });

  final AdjustmentRequestInDb? editingRequest;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustmentRequestMediator.watch(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            if (!viewController.hasItems) {
              context.pop();
              return;
            }
            final res = await DialogManager.confirmActionDialog(
              context,
              '¿Deseas salir sin guardar? (Perderás los cambios)',
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(isEditing ? 'Editar Solicitud de Ajuste' : 'Nueva Solicitud de Ajuste'),
        actions: [
          IconButton(
            tooltip: viewController.validationMessage ?? 'Guardar solicitud',
            onPressed: viewController.canSave
                ? () => saveAdjustmentRequestAction(
                    context,
                    editingRequest: editingRequest,
                  )
                : null,
            icon: const Icon(Icons.save_rounded),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () => addAdjustmentRequestProductAction(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar Producto'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 110),
        children: [
          _MobileFormHeader(editingRequest: editingRequest),
          const SizedBox(height: 10),
          AdjustmentRequestEditorCards(
            viewController: viewController,
            onAddProduct: () => addAdjustmentRequestProductAction(context),
          ),
          const SizedBox(height: 10),
          AdjustmentRequestTotalsBar(
            itemCount: viewController.productCount,
            entryTotal: viewController.totalSurplus,
            exitTotal: viewController.totalShortage,
            compact: true,
          ),
          if (viewController.validationMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              viewController.validationMessage!,
              style: const TextStyle(fontSize: 11.5, color: AppThemeTokens.danger),
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileFormHeader extends StatelessWidget {
  const _MobileFormHeader({required this.editingRequest});

  final AdjustmentRequestInDb? editingRequest;

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustmentRequestMediator.watch(context);
    final authState = getIt<AuthCubit>().state;
    final branchName = authState is Authenticated ? authState.branch.name : '';

    return Card(
      key: viewController.formKey,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TitleTextField(
              title: 'Sucursal',
              initialValue: branchName,
              readOnly: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      const Text('Fecha Doc'),
                      const SizedBox(height: 6),
                      DateFieldSelector(
                        initDate: viewController.docDate,
                        onSelectedDate: (value) {
                          viewController.docDate = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TitleTextField(
              title: 'Observaciones',
              maxLines: 2,
              initialValue: viewController.description,
              onChanged: (value) => viewController.description = value,
            ),
            if (editingRequest != null) ...[
              const SizedBox(height: 8),
              Text(
                'Solicitud ${editingRequest!.docNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.neutral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
