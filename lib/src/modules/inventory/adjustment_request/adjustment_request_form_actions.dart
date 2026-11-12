import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/adjustment_request_mediator.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/write_adjustment_request_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> addAdjustmentRequestProductAction(BuildContext context) async {
  final viewController = AdjustmentRequestMediator.read(context);

  final product = await showSearchProductInBranchDialog(context, useAverageCost: true);
  if (product == null || !context.mounted) return;

  if (viewController.containsProduct(product.id)) {
    await DialogManager.showErrorDialog(
      context,
      'El producto ${product.name} ya está incluido en la solicitud.',
    );
    return;
  }

  final unit = await showInventoryUnitPicker(context, product);
  if (unit == null || !context.mounted) return;

  final factor = UnitConversionTool.ensureSafeFactor(unit.conversionFactor);
  final initialCountedBase = product.account.currentStock < 0 ? 0 : product.account.currentStock;
  final countedQuantity = UnitConversionTool.toDisplayQuantity(initialCountedBase, factor).toDouble();

  final row = AdjustmentRequestRow(
    product: product,
    systemStock: product.account.currentStock,
    countedQuantity: countedQuantity,
    selectedUnitIndex: unit.unitIndex,
    conversionFactor: factor,
    selectedUnitName: unit.unitName,
    unitaryCost: product.account.averageCost * factor,
  );

  final added = viewController.addRow(row);
  if (!added && context.mounted) {
    await DialogManager.showErrorDialog(
      context,
      'El producto ${product.name} ya está incluido en la solicitud.',
    );
  }
}

Future<void> saveAdjustmentRequestAction(
  BuildContext context, {
  AdjustmentRequestInDb? editingRequest,
}) async {
  final viewController = AdjustmentRequestMediator.read(context);
  final validation = viewController.validationMessage;

  if (validation != null) {
    await DialogManager.showErrorDialog(context, validation);
    return;
  }

  final confirm = await DialogManager.slideToConfirmActionDialog(
    context,
    editingRequest == null
        ? '¿Deseas guardar la solicitud de ajuste?'
        : '¿Deseas actualizar la solicitud ${editingRequest.docNumber}?',
  );
  if (confirm != true || !context.mounted) return;

  final writeCubit = context.read<WriteAdjustmentRequestCubit>();

  if (editingRequest == null) {
    final dto = viewController.generateCreateAdjustmentRequest();
    if (dto == null) {
      await DialogManager.showErrorDialog(context, 'No se pudo generar la solicitud.');
      return;
    }
    await writeCubit.create(dto);
    return;
  }

  final dto = viewController.generateUpdateAdjustmentRequest();
  if (dto == null) {
    await DialogManager.showErrorDialog(context, 'No se pudo generar la solicitud.');
    return;
  }
  await writeCubit.update(editingRequest.id, dto);
}
