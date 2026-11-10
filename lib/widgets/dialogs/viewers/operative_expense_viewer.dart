import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/expense_viewer_page.dart';
import 'package:kardex_business/kardex_business.dart';

/// Compatibilidad con las listas de Fase 1.
Future<void> showOperativeExpenseViewerDialog(BuildContext context, ExpenseInDb expense) {
  return showExpenseViewer(context, expense);
}

/// Compatibilidad con las listas de Fase 1.
Future<void> showOperativeExpenseViewerDialogFromId(BuildContext context, String expenseId) {
  return showExpenseViewerFromId(context, expenseId);
}
