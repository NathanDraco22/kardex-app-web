import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/mediator.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/widgets/dialogs/inventory_unit_picker.dart';

import 'widgets/app_bar_menu.dart';

class InventoryExitScreenMobile extends StatelessWidget {
  const InventoryExitScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryExitMediator.read(context);
    return Scaffold(
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final res = await showSearchProductInBranchDelegate(context, true);
            if (res == null) return;
            if (viewController.tableController.rows.length > 99) {
              if (!context.mounted) return;
              await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
              return;
            }
            if (!context.mounted) return;
            final unit = await showInventoryUnitPicker(context, res);
            if (unit == null) return;
            final newRow = ProductRow(
              product: res,
              quantity: 0,
              unitaryCost: (res.account.averageCost * unit.conversionFactor).round(),
              editableCost: false,
              haveExpirationDate: false,
              selectedUnitIndex: unit.unitIndex,
              conversionFactor: unit.conversionFactor,
              selectedUnitName: unit.unitName,
            );
            viewController.tableController.addRow(newRow);
          },
          label: const Text("Agregar Producto"),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final allFields = viewController.hasAllRequiredFields;
            if (!allFields) {
              context.pop();
              return;
            }
            final res = await DialogManager.confirmActionDialog(
              context,
              "Deseas salir sin guardar? (Perderas los cambios)",
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          "Salida de Inventario",
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ExitAppBarMenusButton(),
        ),
      ),
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    final viewController = InventoryExitMediator.read(context);
    return Center(
      child: ListView(
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.only(bottom: 112, top: 8),
        children: [
          const _MobileHeaderSection(
            key: ValueKey("header"),
          ),
          const SizedBox(
            height: 12,
          ),
          Column(
            children: [
              InventoryMovementProductListView(
                controller: viewController.tableController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileHeaderSection extends StatefulWidget {
  const _MobileHeaderSection({
    super.key,
  });

  @override
  State<_MobileHeaderSection> createState() => _MobileHeaderSectionState();
}

class _MobileHeaderSectionState extends State<_MobileHeaderSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewController = InventoryExitMediator.watch(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Cliente",
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                CustomAutocompleteTextfield<ClientInDb>(
                  initValue: viewController.selectedClient,
                  onClose: (value) => viewController.selectedClient = value,
                  titleBuilder: (value) => value.name,
                  onSearch: (value) async {
                    final repo = context.read<ClientsRepository>();
                    try {
                      final res = await repo.searchClientByKeyword(value);
                      return res;
                    } catch (e) {
                      return [];
                    }
                  },
                  suggestionBuilder: (value, close) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final client = value[index];
                        return ListTile(
                          title: Text(client.name),
                          onTap: () {
                            viewController.selectedClient = client;
                            close(client);
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      child: TitleTextField(
                        title: "Documento",
                        initialValue: viewController.docNumber,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          viewController.docNumber = value;
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          const Text("Fecha Doc"),
                          const SizedBox(height: 6),
                          DateFieldSelector(
                            initDate: viewController.docDate,
                            onSelectedDate: (value) {
                              viewController.docDate = value;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                  initialValue: viewController.observations,
                  onChanged: (value) {
                    viewController.observations = value;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
