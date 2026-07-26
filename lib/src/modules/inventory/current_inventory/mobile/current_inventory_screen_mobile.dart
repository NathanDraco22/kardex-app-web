import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/current_inventory_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import '../cubit/read_current_inventory_cubit.dart';
import '../widgets/inventory_mobile_row.dart';
import 'package:kardex_business/kardex_business.dart';

class CurrentInventoryScreenMobile extends StatelessWidget {
  const CurrentInventoryScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadCurrentInventoryCubit>();
    final state = readCubit.state;

    if (state is ReadCurrentInventoryLoading || state is ReadCurrentInventoryInitial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is ReadCurrentInventoryError) {
      return Scaffold(
        appBar: AppBar(title: const Text("Inventario Actual")),
        body: Center(child: Text(state.message)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario Actual"),
        actions: [
          if (state is ReadCurrentInventorySuccess)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                final template = CurrentInventoryTemplate(
                  title: "Inventario Actual",
                  branchName: getIt<AuthCubit>().currentBranchName,
                  items: state.inventories,
                  total: state.total,
                );
                await PdfExportTool.export(
                  template,
                  fileName: "inventario_actual.pdf",
                );
              },
            ),
        ],
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadCurrentInventoryCubit>();
    final state = readCubit.state as ReadCurrentInventorySuccess;
    final totalInventory = NumberFormatter.convertToMoneyLike(state.total);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Productos: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: state.inventories.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Total: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: totalInventory,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SearchFieldDebounced(
                              onSearch: (value) {
                                readCubit.searchInventoryByKeyword(value);
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: state.inventories.length,
                  itemBuilder: (context, index) {
                    final inventory = state.inventories[index];
                    final product = inventory.product;
                    final rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                    return InventoryRow(
                      color: rowColor,
                      productName: product.name,
                      code: product.code ?? "--",
                      brandName: product.brandName,
                      unitName: product.defaultUnitName,
                      stock: NumberFormatter.formatDisplayStock(inventory.currentStock, product.defaultUnitFactor),
                      unitCost: NumberFormatter.convertToMoneyLike(inventory.averageCost * product.defaultUnitFactor),
                      totalValue: NumberFormatter.convertToMoneyLike(inventory.total),
                      image: product.image,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
