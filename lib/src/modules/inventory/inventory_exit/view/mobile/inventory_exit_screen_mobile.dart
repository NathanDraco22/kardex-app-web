import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/mediator.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_delegate.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

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
    final mediator = InventoryExitMediator.read(context)!;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: MediaQuery.viewInsetsOf(context).bottom == 0.0,
        child: FloatingActionButton.extended(
          onPressed: () async {
            final res = await showSearchProductInBranchDelegate(context, true);
            if (res == null) return;
            if (mediator.productListViewController.rowCards.length > 99) {
              if (!context.mounted) return;
              await DialogManager.showErrorDialog(context, "No se pueden agregar mas de 100 productos");
              return;
            }
            final newRow = ProductRowCard(
              product: res,
              quantity: 0,
              unitaryCost: res.account.averageCost,
              editableCost: false,
              haveExpirationDate: false,
            );
            mediator.productListViewController.addRowCard(newRow);
            mediator.refresh();
          },
          label: const Text("Agregar Producto"),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            final allFields = mediator.hasMobileAllRequiredFields();
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
    final mediator = InventoryExitMediator.read(context)!;
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
                controller: mediator.productListViewController,
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
    final mediator = InventoryExitMediator.read(context)!;
    final headerData = mediator.headerData;
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
                  initValue: headerData.client,
                  onClose: (value) => headerData.client = value,
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
                            headerData.client = client;
                            close(client);
                            mediator.refresh();
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
                        initialValue: headerData.docNumber,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          headerData.docNumber = value;
                          mediator.refresh();
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
                            initDate: headerData.docDate,
                            onSelectedDate: (value) {
                              headerData.docDate = value;
                              mediator.refresh();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
