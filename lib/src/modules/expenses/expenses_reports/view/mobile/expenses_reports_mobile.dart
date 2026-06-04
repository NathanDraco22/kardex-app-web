part of '../expenses_reports_view.dart';

class ExpensesReportsMobile extends StatefulWidget {
  const ExpensesReportsMobile({super.key});

  @override
  State<ExpensesReportsMobile> createState() => _ExpensesReportsMobileState();
}

class _ExpensesReportsMobileState extends State<ExpensesReportsMobile> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Gastos"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HeaderSection(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  label: Text("Detalle"),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment<int>(
                  value: 1,
                  label: Text("Resumen"),
                  icon: Icon(Icons.pie_chart_outline),
                ),
              ],
              selected: {_currentIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _currentIndex = newSelection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<ReadExpenseCubit, ReadExpenseState>(
              builder: (context, state) {
                if (state is ReadExpenseLoading || state is ReadExpenseInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ReadExpenseError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    ),
                  );
                }

                if (state is ReadExpenseSuccess) {
                  final items = state.items;
                  final isSearching = state is ReadExpenseSearching;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isSearching)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: LinearProgressIndicator(),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _currentIndex == 0
                              ? _buildMobileDetailedList(items)
                              : ConsolidatedSection(items: items),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDetailedList(List<ExpenseInDb> expenses) {
    if (expenses.isEmpty) {
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final isOperative = expense.type == ExpenseType.operative;
        final concept = isOperative ? expense.category : expense.supplierName;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isOperative ? Icons.business_center : Icons.local_shipping,
                          size: 16,
                          color: isOperative ? Colors.indigo : Colors.teal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOperative ? "Operativo" : "Proveedor",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOperative ? Colors.indigo : Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DateTimeTool.formatddMMyyEs(
                        DateTime.fromMillisecondsSinceEpoch(expense.date),
                      ),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  concept,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (expense.docNumber.isNotEmpty)
                  Text(
                    "Doc: ${expense.docNumber}",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ExpenseReportStatusBadge(status: expense.status),
                    Text(
                      NumberFormatter.convertToMoneyLike(expense.amount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
