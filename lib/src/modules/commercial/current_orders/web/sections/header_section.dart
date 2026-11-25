part of '../current_orders_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  late final TextEditingController _searchController;
  ClientInDb? _selectedClient;
  UserInDb? _selectedUser;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReadOrderCubit>();
    _searchController = TextEditingController(text: cubit.searchKeyword);
    final (isSeller, currentUser) = RoleTools.isSeller();
    if (isSeller) {
      _selectedUser = currentUser;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadOrderCubit>();
    final (isSeller, currentUser) = RoleTools.isSeller();

    if (isSeller && _selectedUser == null) {
      _selectedUser = currentUser;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<OrderStatus?>(
                      initialValue: readCubit.status,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem<OrderStatus?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        DropdownMenuItem<OrderStatus?>(
                          value: OrderStatus.open,
                          child: Text('Abierta'),
                        ),
                        DropdownMenuItem<OrderStatus?>(
                          value: OrderStatus.completed,
                          child: Text('Completada'),
                        ),
                        DropdownMenuItem<OrderStatus?>(
                          value: OrderStatus.cancelled,
                          child: Text('Cancelada'),
                        ),
                      ],
                      onChanged: (value) {
                        readCubit.applyFilters(
                          status: value,
                          clearStatus: value == null,
                        );
                      },
                    ),
                  ),
                  SecondaryMenuButton(
                    onPressed: () async {
                      final client = await showClientSelectionDialog(context);
                      if (client == null || !context.mounted) return;
                      setState(() => _selectedClient = client);
                      await readCubit.applyFilters(clientId: client.id);
                    },
                    icon: const Icon(Icons.business),
                    label: Text(_selectedClient?.name ?? 'Seleccionar cliente'),
                  ),
                  if (!isSeller)
                    UserDropdownSelector(
                      width: 230,
                      selectedUser: _selectedUser,
                      onChanged: (user) {
                        setState(() => _selectedUser = user);
                        readCubit.applyFilters(
                          createdBy: user?.id,
                          clearCreatedBy: user == null,
                        );
                      },
                    ),
                  SizedBox(
                    width: 230,
                    child: TextField(
                      controller: _searchController,
                      onChanged: readCubit.searchOrder,
                      decoration: InputDecoration(
                        labelText: 'Buscar folio o cliente',
                        isDense: true,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Borrar búsqueda',
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  readCubit.searchOrder('');
                                  setState(() {});
                                },
                              ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  SecondaryMenuButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _selectedClient = null;
                        _selectedUser = isSeller ? currentUser : null;
                      });
                      readCubit.clearFilterParams();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Gate(
              filters: const [
                RolePermissionGateFilter(
                  permissions: [CommercialSubModules.createOrder],
                ),
              ],
              child: FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.saleOrder),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nueva Orden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
