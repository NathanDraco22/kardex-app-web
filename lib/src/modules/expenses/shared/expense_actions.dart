import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

/// Acciones disponibles en el menú contextual de una fila de gasto.
enum ExpenseRowAction { edit, markAsPaid, delete }

/// Reglas de negocio compartidas para habilitar acciones sobre un gasto.
class ExpenseActionPermissions {
  const ExpenseActionPermissions._();

  /// La edición/eliminación sigue la regla existente de 4 horas.
  static bool canEditOrDelete(ExpenseInDb expense) {
    return DateTime.now().difference(expense.createdAt).inHours < 4;
  }

  static bool canMarkAsPaid(ExpenseInDb expense) {
    return expense.status == ExpenseStatus.open;
  }
}

/// Acciones compartidas por ambas listas de gastos.
///
/// Todas las escrituras pasan por [WriteExpenseCubit]; el listener del
/// orquestador es quien sincroniza el estado de lectura.
class ExpenseActions {
  const ExpenseActions._();

  /// Abre el formulario de edición correspondiente al tipo de gasto.
  ///
  /// El formulario usa [WriteExpenseCubit] y el listener del orquestador
  /// actualiza la lista al recibir `ExpenseUpdated`.
  static Future<void> edit(
    BuildContext context,
    ExpenseInDb expense, {
    required Future<ExpenseInDb?> Function(BuildContext context, ExpenseInDb expense) openEditor,
  }) async {
    final result = await openEditor(context, expense);
    if (!context.mounted || result == null) return;

    showSnackBar(context, 'Gasto actualizado correctamente');
  }

  static Future<void> markAsPaid(BuildContext context, ExpenseInDb expense) async {
    final confirmed = await DialogManager.slideToConfirmActionDialog(
      context,
      '¿Deseas marcar este gasto como pagado?',
    );
    if (confirmed != true || !context.mounted) return;

    final writeCubit = context.read<WriteExpenseCubit>();
    LoadingDialogManager.showLoadingDialog(context);

    var succeeded = false;
    try {
      succeeded = await writeCubit.update(
        expense.id,
        UpdateExpense(
          status: ExpenseStatus.paid,
          expirationDate: null,
        ),
      );
    } finally {
      if (context.mounted) {
        LoadingDialogManager.closeLoadingDialog(context);
      }
    }

    if (!context.mounted) return;
    if (!succeeded) {
      final state = writeCubit.state;
      if (state is WriteExpenseError) {
        await DialogManager.showErrorDialog(context, state.message);
      }
      return;
    }

    showSnackBar(context, 'Gasto marcado como pagado');
  }

  static Future<void> delete(BuildContext context, ExpenseInDb expense) async {
    final confirmed = await DialogManager.slideToConfirmActionDialog(
      context,
      '¿Deseas eliminar este gasto?',
    );
    if (confirmed != true || !context.mounted) return;

    final writeCubit = context.read<WriteExpenseCubit>();
    LoadingDialogManager.showLoadingDialog(context);

    var succeeded = false;
    try {
      succeeded = await writeCubit.delete(expense.id);
    } finally {
      if (context.mounted) {
        LoadingDialogManager.closeLoadingDialog(context);
      }
    }

    if (!context.mounted) return;
    if (!succeeded) {
      final state = writeCubit.state;
      if (state is WriteExpenseError) {
        await DialogManager.showErrorDialog(context, state.message);
      }
      return;
    }

    showSnackBar(context, 'Gasto eliminado');
  }

  static void showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0F172A),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
