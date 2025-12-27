part of '../sale_projection_screen_web.dart';

class _ContentSection extends StatefulWidget {
  final int projectionDays;

  const _ContentSection({
    required this.projectionDays,
  });

  @override
  State<_ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<_ContentSection> {
  @override
  void initState() {
    super.initState();
    // Carga inicial con la sucursal actual
    final branchId = BranchesTool.getCurrentBranchId();
    context.read<ReadSaleProjectionCubit>().getAllWithAccount(branchId: branchId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadSaleProjectionCubit, ReadSaleProjectionState>(
      builder: (context, state) {
        if (state is ReadSaleProjectionLoading) {
          return const Center(child: LinearProgressIndicator());
        }

        if (state is ReadSaleProjectionFailure) {
          return Center(
            child: Text("Error: ${state.message}"),
          );
        }

        if (state is ReadSaleProjectionSuccess) {
          final stats = state.stats;
          if (stats.isEmpty) {
            return const Center(child: Text("No hay datos disponibles."));
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Producto",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Inv. Actual",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Prom. Diario",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Costo Und.",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Proyección",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Costo Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Clasificación",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final item = stats[index];
                        final tileColor = index % 2 == 0 ? Colors.grey[200] : Colors.transparent;

                        final stock = item.account.currentStock;
                        final daily = item.unitsPerDay;
                        final needed = (daily * widget.projectionDays) - stock;

                        // Si needed > 0, es la cantidad a comprar.
                        // Si needed <= 0, hay exceso.
                        final isDeficit = needed > 0;
                        final displayNeeded = needed;
                        final totalCost = displayNeeded * item.account.averageCostMoney;

                        // Estilo para la columna Proyección
                        final projectionColor = isDeficit ? Colors.green : Colors.red;
                        final projectionText = isDeficit
                            ? NumberFormatter.decimalPattern(needed)
                            : NumberFormatter.decimalPattern(needed);

                        return Container(
                          color: tileColor,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Text(item.product.brandName),
                                        Text(item.product.unitName),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  stock.toString(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  NumberFormatter.decimalPattern(daily),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  NumberFormatter.convertToMoneyLike(item.account.averageCost),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  projectionText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: projectionColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  isDeficit
                                      ? NumberFormatter.convertToMoneyLike(
                                          NumberFormatter.convertFromDoubleToCents(totalCost),
                                        )
                                      : "-",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: _ClassificationBadge(
                                  level: item.estimationLevel,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text("Cargando..."));
      },
    );
  }
}

class _ClassificationBadge extends StatelessWidget {
  final int level;

  const _ClassificationBadge({required this.level});

  ({String label, Color color, Color textColor}) _getStyle() {
    switch (level) {
      case 5:
        return (label: "ALTO (5)", color: Colors.green, textColor: Colors.white);
      case 4:
        return (label: "BUENO (4)", color: Colors.lightGreen, textColor: Colors.black);
      case 3:
        return (label: "REGULAR (3)", color: Colors.amber, textColor: Colors.black);
      case 2:
        return (label: "BAJO (2)", color: Colors.orangeAccent, textColor: Colors.black);
      case 1:
        return (label: "MIN (1)", color: Colors.redAccent, textColor: Colors.white);
      default:
        return (label: "N/A ($level)", color: Colors.grey, textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        style.label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: style.textColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
