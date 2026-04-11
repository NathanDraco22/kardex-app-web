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
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadProformaCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final client = await showClientSelectionDialog(context);
                    if (client == null) return;
                    setState(() {
                      currentSelectedClient = client;
                    });
                    readCubit.setFilterParams(
                      clientId: currentSelectedClient?.id,
                      createdBy: currentSelectedUser?.id,
                    );
                    readCubit.loadPaginatedOrders();
                  },
                  icon: const Icon(Icons.business),
                  label: Text(currentSelectedClient?.name ?? "Seleccionar cliente"),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final user = await showActiveUserSelectionDialog(context);
                    if (user == null) return;
                    setState(() {
                      currentSelectedUser = user;
                    });
                    readCubit.setFilterParams(
                      clientId: currentSelectedClient?.id,
                      createdBy: currentSelectedUser?.id,
                    );
                    readCubit.loadPaginatedOrders();
                  },
                  icon: const Icon(Icons.person),
                  label: Text(currentSelectedUser?.username ?? "Seleccionar usuario"),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  currentSelectedUser = null;
                  currentSelectedClient = null;
                });
                readCubit.clearFilterParams();
              },
              icon: const Icon(Icons.clear),
              label: const Text("Limpiar"),
            ),
          ],
        ),
      ),
    );
  }
}
