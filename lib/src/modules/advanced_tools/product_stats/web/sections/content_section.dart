part of '../product_stats_web_screen.dart';

class _ContentSection extends StatefulWidget {
  const _ContentSection();

  @override
  State<_ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<_ContentSection> {
  @override
  void initState() {
    super.initState();

    context.read<ReadProductStatsCubit>().getAllWithInfo(
      branchId: BranchesTool.getCurrentBranchId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadProductStatsCubit, ReadProductStatsState>(
      builder: (context, state) {
        if (state is ReadProductStatsLoading) {
          return const Center(child: LinearProgressIndicator());
        }

        if (state is ReadProductStatsFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${state.message}"),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReadProductStatsCubit>().getAllWithInfo();
                  },
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          );
        }

        if (state is ReadProductStatsSuccess) {
          final stats = state.stats;

          if (stats.isEmpty) {
            return const Center(child: Text("No hay estadísticas disponibles."));
          }

          // Usamos el primer elemento para la metadata del header (asumiendo homogeneidad en la consulta)
          final first = stats.first;
          final lastEstimationDate = DateTime.fromMillisecondsSinceEpoch(first.lastEstimation);
          final startDate = DateTime.fromMillisecondsSinceEpoch(first.startDate);
          final endDate = DateTime.fromMillisecondsSinceEpoch(first.endDate);

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Ultima Estimación: ${DateTimeTool.formatddMMyyEs(lastEstimationDate)}"),
                  Text("Periodo: ${DateTimeTool.formatddMMyyEs(startDate)} - ${DateTimeTool.formatddMMyyEs(endDate)}"),
                  Text("Dias Analizados: ${first.daysAnalyzed}"),
                  const Divider(),
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
                            "Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Diario",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Frecuencia",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Clasificacion",
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
                        return Container(
                          padding: const EdgeInsets.all(8),
                          color: tileColor,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
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
                                  item.totalUnits.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  NumberFormatter.decimalPattern(item.unitsPerDay),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  NumberFormatter.decimalPattern(item.frecuency),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
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

        return const Center(child: Text("Iniciando..."));
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
