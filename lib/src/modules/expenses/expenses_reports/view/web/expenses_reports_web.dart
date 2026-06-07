part of '../expenses_reports_view.dart';

class ExpensesReportsWeb extends StatefulWidget {
  const ExpensesReportsWeb({super.key});

  @override
  State<ExpensesReportsWeb> createState() => _ExpensesReportsWebState();
}

class _ExpensesReportsWebState extends State<ExpensesReportsWeb> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte General de Gastos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeaderSection(),

            Center(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text("Vista Detallada"),
                    icon: Icon(Icons.list_alt),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text("Consolidado / Resumen"),
                    icon: Icon(Icons.pie_chart),
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
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
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
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: LinearProgressIndicator(),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _currentIndex == 0
                                ? DetailedExpensesTable(items: items)
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
      ),
    );
  }
}
