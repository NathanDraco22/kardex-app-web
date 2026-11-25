part of '../current_proforma_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;
  ClientInDb? currentSelectedClient;

  @override
  void initState() {
    super.initState();
    final (isSeller, currentUser) = RoleTools.isSeller();
    if (isSeller && currentUser != null) {
      currentSelectedUser = currentUser;
    }
  }

  void _reloadOrders(BuildContext context) {
    final (isSeller, currentUser) = RoleTools.isSeller();
    final readCubit = context.read<ReadProformaCubit>();
    readCubit.setFilterParams(
      clientId: currentSelectedClient?.id,
      createdBy: isSeller ? currentUser?.id : currentSelectedUser?.id,
    );
    readCubit.loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadProformaCubit>();
    final (isSeller, currentUser) = RoleTools.isSeller();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SecondaryMenuButton(
                  onPressed: () async {
                    final client = await showClientSelectionDialog(context);
                    if (client == null || !context.mounted) return;
                    setState(() {
                      currentSelectedClient = client;
                    });
                    _reloadOrders(context);
                  },
                  icon: const Icon(Icons.business),
                  label: Text(currentSelectedClient?.name ?? 'Seleccionar cliente'),
                ),
                if (!isSeller)
                  UserDropdownSelector(
                    width: 240,
                    selectedUser: currentSelectedUser,
                    onChanged: (user) {
                      setState(() {
                        currentSelectedUser = user;
                      });
                      _reloadOrders(context);
                    },
                  ),
                SecondaryMenuButton(
                  onPressed: () {
                    setState(() {
                      currentSelectedUser = isSeller ? currentUser : null;
                      currentSelectedClient = null;
                    });
                    readCubit.clearFilterParams();
                    readCubit.loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar'),
                ),
              ],
            ),
            Gate(
              filters: const [
                RolePermissionGateFilter(
                  permissions: [CommercialSubModules.createOrder],
                ),
              ],
              child: FilledButton.icon(
                onPressed: () => _openCreateProforma(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nueva Cotización'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
