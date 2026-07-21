part of '../adjust_exit_screen.dart';

class AdjustExitMobileScreen extends StatelessWidget {
  const AdjustExitMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    final mediator = AdjustExitMediator.read(context)!;
    final type = mediator.type;
    String title = switch (type) {
      .adjust => "Salida por Ajuste de Inventario",
      .devolution => "Devoluciones",
      .loss => "Mermas",
    };
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
            if (!context.mounted) return;
            final unit = await showInventoryUnitPicker(context, res);
            if (unit == null) return;
            final newRow = ProductRowCard(
              product: res,
              quantity: 0,
              unitaryCost: res.account.averageCost * unit.conversionFactor,
              editableCost: false,
              haveExpirationDate: false,
              selectedUnitIndex: unit.unitIndex,
              conversionFactor: unit.conversionFactor,
              selectedUnitName: unit.unitName,
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
              "¿Deseas salir sin guardar? (Perderás los cambios)",
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (!mediator.hasMobileAllRequiredFields() || mediator.hasMobileProductWithZeroValue()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Complete todos los campos y asegúrese de que las cantidades sean mayores a 0"),
                  ),
                );
                return;
              }

              final res = await DialogManager.slideToConfirmActionDialog(
                context,
                "¿Deseas guardar la Salida? (No se puede deshacer)",
              );
              if (res != true) return;
              if (!context.mounted) return;

              final authState = getIt<AuthCubit>().state as Authenticated;
              final currentUser = authState.session.user;

              final items = mediator.productListViewController.rowCards.map((card) {
                return AdjustExitItem(
                  productId: card.product.id,
                  productName: card.product.name,
                  cost: UnitConversionTool.toBaseCost(card.unitaryCost, card.conversionFactor),
                  quantity: UnitConversionTool.toBaseQuantity(card.quantity, card.conversionFactor) * -1,
                  conversionFactor: card.conversionFactor,
                  code: card.product.code,
                  brandName: card.product.brandName,
                  unitName: UnitConversionTool.resolveUnitName(card.selectedUnitName, card.product.unitName),
                );
              }).toList();

              final createDto = CreateAdjustExit(
                branchId: authState.branch.id,
                description: mediator.headerData.description ?? "",
                type: mediator.headerData.type,
                items: items,
                createdBy: UserInfo(
                  id: currentUser.id,
                  name: currentUser.username,
                ),
              );

              context.read<WriteAdjustExitCubit>().createAdjustExit(createDto);
            },
          ),
        ],
      ),
      body: const _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    final mediator = AdjustExitMediator.read(context)!;
    return Center(
      child: ListView(
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.only(bottom: 112, top: 8),
        children: [
          const _MobileHeaderSection(key: ValueKey("header")),
          const SizedBox(height: 12),
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
  const _MobileHeaderSection({super.key});

  @override
  State<_MobileHeaderSection> createState() => _MobileHeaderSectionState();
}

class _MobileHeaderSectionState extends State<_MobileHeaderSection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediator = AdjustExitMediator.read(context)!;
    final headerData = mediator.headerData;
    final currentBranch = (getIt<AuthCubit>().state as Authenticated).branch;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TitleTextField(
                  title: "Sucursal",
                  initialValue: currentBranch.name,
                  readOnly: true,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          const Text("Fecha Doc"),
                          const SizedBox(height: 6),
                          DateFieldSelector(
                            initDate: DateTime.now(),
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
                TitleTextField(
                  title: "Observaciones",
                  maxLines: 2,
                  onChanged: (val) {
                    headerData.description = val;
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
