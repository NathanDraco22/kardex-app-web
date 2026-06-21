import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/expenses/read_expenses_cubit.dart';
import 'package:kardex_app_front/src/domain/models/expense/expense_model.dart';
import 'package:kardex_app_front/src/domain/query_params/expense_query_params.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/src/tools/exports/csv_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/expenses_report_template.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_app_front/widgets/dialogs/export_options_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReadExpenseCubit>();
    if (cubit.queryParams.startDate != null) {
      _startDate = DateTime.fromMillisecondsSinceEpoch(cubit.queryParams.startDate!);
    } else {
      _startDate = DateTime.now().startOfDay();
    }
    if (cubit.queryParams.endDate != null) {
      _endDate = DateTime.fromMillisecondsSinceEpoch(cubit.queryParams.endDate!);
    } else {
      _endDate = DateTime.now().endOfDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadExpenseCubit>();
    final authCubit = getIt<AuthCubit>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filtros de Reporte",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    final today = DateTime.now();
                    setState(() {
                      _startDate = today.startOfDay();
                      _endDate = today.endOfDay();
                    });
                    final params = ExpenseQueryParams()
                      ..branchId = authCubit.currentBranchId
                      ..startDate = today.startOfDay().millisecondsSinceEpoch
                      ..endDate = today.endOfDay().millisecondsSinceEpoch;
                    cubit.getAll(params);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text("Limpiar Filtros"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 220,
                  child: DatePickerListTile(
                    key: ValueKey("start_date_${_startDate?.millisecondsSinceEpoch}"),
                    title: "Fecha Inicio",
                    defaultDate: _startDate,
                    onSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: DatePickerListTile(
                    key: ValueKey("end_date_${_endDate?.millisecondsSinceEpoch}"),
                    title: "Fecha Fin",
                    defaultDate: _endDate,
                    onSelected: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        final params = ExpenseQueryParams()..branchId = authCubit.currentBranchId;
                        if (_startDate != null) {
                          params.startDate = _startDate!.startOfDay().millisecondsSinceEpoch;
                        }
                        if (_endDate != null) {
                          params.endDate = _endDate!.endOfDay().millisecondsSinceEpoch;
                        }
                        cubit.getAll(params);
                      },
                      icon: const Icon(Icons.filter_alt),
                      label: const Text("Filtrar"),
                    ),
                    const SizedBox(width: 12),
                    if (cubit.state is ReadExpenseSuccess) ...[
                      OutlinedButton.icon(
                        onPressed: () async {
                          final state = cubit.state as ReadExpenseSuccess;
                          if (state.items.isEmpty) return;

                          final option = await showExportOptionsDialog(context);
                          if (option == null) return;

                          final startText = _startDate != null ? DateTimeTool.formatddMMyyEs(_startDate!) : "inicio";
                          final endText = _endDate != null ? DateTimeTool.formatddMMyyEs(_endDate!) : "fin";
                          final periodText = "${startText}_a_$endText";

                          if (option == ExportOption.csv) {
                            await CsvExportTool.exportExpensesToCSV(
                              expenses: state.items,
                              fileName: "reporte_gastos_$periodText",
                            );
                          } else if (option == ExportOption.pdf) {
                            final template = ExpensesReportTemplate(
                              title: "Reporte General de Gastos",
                              branchName: authCubit.currentBranchName,
                              startDate: _startDate,
                              endDate: _endDate,
                              items: state.items,
                            );
                            await PdfExportTool.export(
                              template,
                              fileName: "reporte_gastos_$periodText.pdf",
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text("Exportar"),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedExpensesTable extends StatelessWidget {
  final List<ExpenseInDb> items;

  const DetailedExpensesTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: NoItemWidget(
            icon: Icons.monetization_on_outlined,
            text: "No se encontraron gastos en este periodo",
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text("Tipo", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("N° Documento", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: Text("Concepto / Categoría", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Fecha", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Estado", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text("Monto", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final expense = items[index];
              final isOperative = expense.type == ExpenseType.operative;
              final concept = isOperative ? expense.category : expense.supplierName;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Icon(
                            isOperative ? Icons.business_center : Icons.local_shipping,
                            size: 18,
                            color: isOperative ? Colors.indigo : Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          Text(isOperative ? "Operativo" : "Proveedor"),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(expense.docNumber.isEmpty ? "—" : expense.docNumber),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        concept,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        DateTimeTool.formatddMMyyEs(
                          DateTime.fromMillisecondsSinceEpoch(expense.date),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ExpenseReportStatusBadge(status: expense.status),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          NumberFormatter.convertToMoneyLike(expense.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ConsolidatedSection extends StatelessWidget {
  final List<ExpenseInDb> items;

  const ConsolidatedSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final operativeExpenses = items.where((e) => e.type == ExpenseType.operative).toList();
    final supplierExpenses = items.where((e) => e.type == ExpenseType.supplier).toList();

    // Agrupación de Gastos Operativos por Categoría
    final Map<String, int> operativeByCategory = {};
    int totalOperative = 0;
    for (final e in operativeExpenses) {
      operativeByCategory[e.category] = (operativeByCategory[e.category] ?? 0) + e.amount;
      totalOperative += e.amount;
    }

    // Agrupación de Gastos a Proveedores por Nombre
    final Map<String, int> supplierBySupplierName = {};
    int totalSupplier = 0;
    for (final e in supplierExpenses) {
      final name = e.supplierName.isEmpty ? 'Desconocido' : e.supplierName;
      supplierBySupplierName[name] = (supplierBySupplierName[name] ?? 0) + e.amount;
      totalSupplier += e.amount;
    }

    final grandTotal = totalOperative + totalSupplier;

    final isMobile = MediaQuery.sizeOf(context).width < 800;

    final content = [
      // Columna Izquierda: Gastos Operativos
      Expanded(
        flex: isMobile ? 0 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: "Gastos Operativos",
              totalAmount: totalOperative,
              icon: Icons.business_center,
              iconColor: Colors.indigo,
            ),
            const SizedBox(height: 8),
            _buildConsolidationTable(operativeByCategory, "Categoría"),
          ],
        ),
      ),
      if (!isMobile) const SizedBox(width: 24),
      if (isMobile) const SizedBox(height: 24),
      // Columna Derecha: Gastos a Proveedores
      Expanded(
        flex: isMobile ? 0 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              title: "Gastos Proveedores",
              totalAmount: totalSupplier,
              icon: Icons.local_shipping,
              iconColor: Colors.teal,
            ),
            const SizedBox(height: 8),
            _buildConsolidationTable(supplierBySupplierName, "Proveedor"),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gran Total destacado
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Total Gastos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Text(
                  NumberFormatter.convertToMoneyLike(grandTotal),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: content,
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content,
          ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int totalAmount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Text(
            NumberFormatter.convertToMoneyLike(totalAmount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsolidationTable(Map<String, int> data, String nameHeader) {
    if (data.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              "Sin gastos registrados",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
        ),
      );
    }

    final sortedEntries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nameHeader,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    Text(
                      NumberFormatter.convertToMoneyLike(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ExpenseReportStatusBadge extends StatelessWidget {
  final ExpenseStatus status;

  const ExpenseReportStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        constraints: const BoxConstraints(minWidth: 80),
        decoration: BoxDecoration(
          color: _statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            _statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (status) {
      case ExpenseStatus.draft:
        return Colors.grey;
      case ExpenseStatus.open:
        return Colors.orange;
      case ExpenseStatus.paid:
        return Colors.green;
      case ExpenseStatus.partiallyPaid:
        return Colors.blue;
      case ExpenseStatus.cancelled:
        return Colors.red;
    }
  }

  String get _statusLabel {
    switch (status) {
      case ExpenseStatus.draft:
        return "Borrador";
      case ExpenseStatus.open:
        return "Pendiente";
      case ExpenseStatus.paid:
        return "Pagado";
      case ExpenseStatus.partiallyPaid:
        return "Parcial";
      case ExpenseStatus.cancelled:
        return "Cancelado";
    }
  }
}
