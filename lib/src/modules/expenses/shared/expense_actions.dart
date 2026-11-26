import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/write_expenses_cubit.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/dialogs/register_expense_payment_dialog.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

/// Acciones disponibles en el menú contextual de una fila de gasto.
enum ExpenseRowAction { edit, registerPayment, markAsPaid, delete }

/// Reglas de negocio compartidas para habilitar acciones sobre un gasto.
class ExpenseActionPermissions {
  const ExpenseActionPermissions._();

  static bool hasPayments(ExpenseInDb expense) {
    return expense.payments.isNotEmpty || expense.status == ExpenseStatus.partiallyPaid;
  }

  /// La edición/eliminación sigue la regla existente de 4 horas y bloquea
  /// gastos que ya tienen abonos registrados.
  static bool canEditOrDelete(ExpenseInDb expense) {
    if (hasPayments(expense)) return false;
    return DateTime.now().difference(expense.createdAt).inHours < 4;
  }

  static bool canRegisterPayment(ExpenseInDb expense) {
    return (expense.status == ExpenseStatus.open || expense.status == ExpenseStatus.partiallyPaid) &&
        expense.remainingAmount > 0;
  }

  static bool canMarkAsPaid(ExpenseInDb expense) {
    return (expense.status == ExpenseStatus.open || expense.status == ExpenseStatus.partiallyPaid) &&
        expense.remainingAmount > 0;
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

  static Future<ExpenseInDb?> registerPayment(
    BuildContext context,
    ExpenseInDb expense, {
    bool prefillFullBalance = false,
  }) async {
    final updated = await showRegisterExpensePaymentDialog(
      context,
      expense: expense,
      prefillFullBalance: prefillFullBalance,
    );
    if (!context.mounted || updated == null) return null;

    showSnackBar(
      context,
      updated.status == ExpenseStatus.paid ? 'Gasto liquidado correctamente' : 'Abono registrado correctamente',
    );
    return updated;
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
      final remaining = expense.remainingAmount;
      if (remaining > 0) {
        final currentUser = getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>().user : null;
        final updated = await writeCubit.addPayment(
          AddToAmountRequest(
            expenseId: expense.id,
            amountPaid: remaining,
            paymentMethod: ExpensePaymentMethod.cash,
            note: 'Pago total',
            paidAt: DateTime.now().millisecondsSinceEpoch,
            createdBy: currentUser != null ? UserInfo(id: currentUser.id, name: currentUser.username) : null,
          ),
        );
        succeeded = updated != null;
      } else {
        succeeded = await writeCubit.update(
          expense.id,
          UpdateExpense(
            status: ExpenseStatus.paid,
            expirationDate: null,
          ),
        );
      }
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
