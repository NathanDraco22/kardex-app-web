import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/terminal_draft_manager.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/read_terminal_product_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/widgets/hold_sales_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

/// Procesa la búsqueda en la terminal de venta con soporte para escáner
/// de código de barras y auto-agregado por coincidencia exacta de código.
Future<void> processTerminalSearch({
  required BuildContext context,
  required String value,
  required SaleTerminalViewController viewController,
  required TextEditingController searchController,
  required bool isSubmitted,
  VoidCallback? onCleared,
}) async {
  final query = value.trim();
  if (query.isEmpty) {
    context.read<ReadTerminalProductCubit>().searchProducts('');
    return;
  }

  final results = await context.read<ReadTerminalProductCubit>().searchProducts(query);
  if (!context.mounted) return;

  ProductInDbInBranch? exactMatch;
  for (final p in results) {
    if (p.code.trim().toLowerCase() == query.toLowerCase()) {
      exactMatch = p;
      break;
    }
  }

  if (exactMatch != null) {
    final added = viewController.quickAddProduct(context, exactMatch);
    if (added) {
      searchController.clear();
      context.read<ReadTerminalProductCubit>().searchProducts('');
      onCleared?.call();
    }
  } else if (isSubmitted && results.length == 1) {
    final singleProduct = results.first;
    final added = viewController.quickAddProduct(context, singleProduct);
    if (added) {
      searchController.clear();
      context.read<ReadTerminalProductCubit>().searchProducts('');
      onCleared?.call();
    }
  }

  viewController.requestSearchFocus();
}

/// Guarda la venta actual en espera mediante SaleTerminalDraftManager.
Future<void> holdTerminalSale(
  BuildContext context, {
  required SaleTerminalViewController viewController,
  VoidCallback? onHoldCompleted,
}) async {
  if (viewController.items.isEmpty) return;

  final authState = getIt<AuthCubit>().state;
  if (authState is! Authenticated) return;

  final draft = viewController.exportToDraft();
  await SaleTerminalDraftManager().saveDraft(authState.branch.id, draft);

  onHoldCompleted?.call();
  viewController.clear();

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Venta guardada en espera"),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Abre el diálogo modal de ventas en espera.
void openHoldSalesModal(
  BuildContext context, {
  required SaleTerminalViewController viewController,
}) {
  final authState = getIt<AuthCubit>().state;
  if (authState is! Authenticated) return;

  showHoldSalesDialog(
    context,
    branchId: authState.branch.id,
    viewController: viewController,
  );
}

/// Solicita confirmación al usuario antes de vaciar los productos de la venta actual.
Future<void> confirmAndClearCart(
  BuildContext context, {
  required SaleTerminalViewController viewController,
  VoidCallback? onCleared,
}) async {
  if (viewController.items.isEmpty) return;

  final confirm = await DialogManager.confirmActionDialog(
    context,
    "¿Estás seguro de que deseas vaciar todos los productos de la venta actual?",
  );
  if (confirm != true) return;

  onCleared?.call();
  viewController.clear();
}
