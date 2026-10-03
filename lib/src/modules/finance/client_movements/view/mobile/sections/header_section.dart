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
                  SecondaryMenuButton(
                    onPressed: () async {
                      final client = await showClientSelectionDialog(context);
                      if (client == null) return;
                      setState(() {
                        selectedClient = client;
                      });
                      readCubit.loadPaginatedTransactions(
                        client: selectedClient!,
                        endDate: selectedDay,
                      );
                    },
                    label: const Text("Buscar Cliente"),
                    icon: const Icon(Icons.business),
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
