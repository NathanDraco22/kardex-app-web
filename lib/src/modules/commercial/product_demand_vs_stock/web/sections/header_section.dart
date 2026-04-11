part of '../product_demand_vs_stock_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadProductStockDemandCubit>();
    final state = readCubit.state;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Resultados Actuales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (state is ReadProductStockDemandSuccess)
              FilledButton.icon(
                onPressed: () async {
                  final template = ProductDemandVsStockTemplate(
                    title: "Cotizaciones vs Existencias",
                    branchName: BranchesTool.getCurrentBranchName(),
                    items: state.results,
                  );
                  await PdfExportTool.export(
                    template,
                    fileName: "cotizaciones_vs_existencias.pdf",
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Exportar PDF"),
              ),
          ],
        ),
      ),
    );
  }
}
