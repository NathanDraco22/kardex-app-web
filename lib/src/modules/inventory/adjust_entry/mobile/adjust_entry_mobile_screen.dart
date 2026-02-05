part of '../adjust_entry_screen.dart';

class AdjustEntryMobileScreen extends StatelessWidget {
  const AdjustEntryMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    final mediator = AdjustEntryMediator.read(context)!;
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
              "¿Deseas salir sin guardar? (Perderás los cambios)",
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Entrada por Ajuste de Inventario"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (!mediator.hasMobileAllRequiredFields() || mediator.hasMobileProductWithZeroValue()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Complete todos los campos")));
                return;
              }

              final res = await DialogManager.slideToConfirmActionDialog(
                context,
                "¿Deseas guardar el Ajuste? (No se puede deshacer)",
              );
              if (res != true) return;
              if (!context.mounted) return;
              final authState = context.read<AuthCubit>().state as Authenticated;
              final items = mediator.productListViewController.rowCards.map((card) {
                return EntryItem(
                  productId: card.product.id,
                  productName: card.product.name,
                  cost: card.unitaryCost,
                  quantity: card.quantity,
                  expirationDate: card.expirationDate?.millisecondsSinceEpoch,
                  code: card.product.code,
                  brandName: card.product.brandName,
                  unitName: card.product.unitName,
                );
              }).toList();

              final currentUser = authState.session.user;

              final createDto = CreateAdjustEntry(
                branchId: authState.branch.id,
                description: mediator.headerData.description ?? "",
                items: items,
                createdBy: UserInfo(id: currentUser.id, name: currentUser.username),
              );

              context.read<WriteAdjustEntryCubit>().createAdjustEntry(createDto);
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
    final mediator = AdjustEntryMediator.read(context)!;
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
    final mediator = AdjustEntryMediator.read(context)!;
    final headerData = mediator.headerData;
    final currentBranch = (context.read<AuthCubit>().state as Authenticated).branch;

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
