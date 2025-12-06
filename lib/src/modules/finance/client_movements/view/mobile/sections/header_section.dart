part of '../client_movements_screen_mobile.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection({this.initialClient});

  final ClientInDb? initialClient;

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  DateTime selectedDay = DateTime.now();
  ClientInDb? selectedClient;

  @override
  void initState() {
    super.initState();
    selectedClient = widget.initialClient;
    if (selectedClient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReadClientTransactionCubit>().loadPaginatedTransactions(
          client: selectedClient!,
          endDate: selectedDay,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadClientTransactionCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (widget.initialClient == null)
                  TextButton.icon(
                    onPressed: () async {
                      // TODO: Implement Client Search Delegate or Dialog
                      // For now, we might rely on passing the client from the previous screen
                      // But if this is a standalone screen, we need search.
                      // We will implement a search delegate in the next step.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Búsqueda de clientes pendiente de implementar")),
                      );
                    },
                    label: const Text("Buscar Cliente"),
                    icon: const Icon(Icons.search),
                  ),

                SizedBox(
                  width: 150,
                  child: DatePickerListTile(
                    defaultDate: selectedDay,
                    title: "Fecha",
                    onSelected: (value) {
                      selectedDay = value;
                      if (selectedClient == null) return;
                      readCubit.loadPaginatedTransactions(
                        client: selectedClient!,
                        endDate: selectedDay,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
