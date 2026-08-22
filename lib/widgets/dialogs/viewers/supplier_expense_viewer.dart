import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

Future<void> showSupplierExpenseViewerDialog(BuildContext context, ExpenseInDb expense) async {
  if (!context.mounted) return;
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => _SupplierExpenseViewer(expense: expense),
    ),
  );
}

Future<void> showSupplierExpenseViewerDialogFromId(BuildContext context, String expenseId) async {
  if (!context.mounted) return;
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<ExpenseInDb?>(
          future: context.read<ExpensesRepository>().getExpenseById(expenseId),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: Text("Error al cargar el gasto de proveedor \n ${asyncSnapshot.error}"),
                ),
              );
            }

            final expense = asyncSnapshot.data!;
            return _SupplierExpenseViewer(expense: expense);
          },
        );
      },
    ),
  );
}

class _SupplierExpenseViewer extends StatelessWidget {
  const _SupplierExpenseViewer({required this.expense});

  final ExpenseInDb expense;

  @override
  Widget build(BuildContext context) {
    final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;

    final isExpired = expense.expirationDate != null &&
        DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!).isBefore(DateTime.now()) &&
        expense.status != ExpenseStatus.paid &&
        expense.status != ExpenseStatus.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: Text("Gasto Proveedor #${expense.docNumber.isEmpty ? "S/N" : expense.docNumber}"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Gasto a Proveedor",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentBranch.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 32, thickness: 1.2),
                      _buildDetailRow("Proveedor", expense.supplierName.isEmpty ? "—" : expense.supplierName),
                      _buildDetailRow("N° Documento", expense.docNumber.isEmpty ? "—" : expense.docNumber),
                      _buildDetailRow("Categoría", expense.category),
                      _buildDetailRow(
                        "Monto",
                        NumberFormatter.convertToMoneyLike(expense.amount),
                        valueStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      _buildDetailRow(
                        "Fecha Documento",
                        DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(expense.date)),
                      ),
                      _buildDetailRow(
                        "Estado",
                        expense.status == ExpenseStatus.paid ? "Pagado" : "Pendiente",
                        valueColor: expense.status == ExpenseStatus.paid ? Colors.green : Colors.orange,
                      ),
                      if (expense.expirationDate != null)
                        _buildDetailRow(
                          "Fecha Vencimiento",
                          DateTimeTool.formatddMMyyEs(DateTime.fromMillisecondsSinceEpoch(expense.expirationDate!)),
                          valueColor: isExpired ? Colors.red : null,
                        ),
                      _buildDetailRow("Elaborado por", expense.createdBy.name),
                      if (expense.description != null && expense.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "Observaciones / Descripción",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            expense.description!,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: valueStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
