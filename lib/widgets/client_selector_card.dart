import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/buttons/secondary_menu_button.dart';
import 'package:kardex_app_front/widgets/dialogs/client_full_details_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';

class ClientSelectorCard extends StatefulWidget {
  const ClientSelectorCard({
    super.key,
    required this.onChange,
    this.initialClient,
  });

  final void Function(ClientInDb?) onChange;
  final ClientInDb? initialClient;

  @override
  State<ClientSelectorCard> createState() => _ClientSelectorCardState();
}

class _ClientSelectorCardState extends State<ClientSelectorCard> {
  ClientInDb? _selectedClient;

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.initialClient;
  }

  @override
  Widget build(BuildContext context) {
    final unSelectClient = Column(
      crossAxisAlignment: .center,
      mainAxisAlignment: .center,
      children: [
        Expanded(
          child: SecondaryMenuButton(
            onPressed: () async {
              _selectedClient = await showClientSelectionDialog(context);
              widget.onChange(_selectedClient);
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text("Agregar Cliente"),
          ),
        ),
      ],
    );

    final selectedClient = Ink(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: .stretch,
            mainAxisAlignment: .start,
            children: [
              Row(
                children: [
                  const Text(
                    "Datos del Cliente",
                    style: TextStyle(fontWeight: .w500, color: Colors.grey),
                  ),
                  SecondaryMenuButton(
                    onPressed: () async {
                      showClientFullDetailsDialog(context, client: _selectedClient!);
                    },
                    icon: const Icon(Icons.info),
                    label: const Text("ver mas.."),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _selectedClient = null;
                      widget.onChange(_selectedClient);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.delete,
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              Text(
                _selectedClient?.name ?? "",
                style: const TextStyle(
                  fontWeight: .w500,
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
              Text(_selectedClient?.location ?? ""),
              Text(_selectedClient?.address ?? ""),
              const Divider(
                height: 2,
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    "Saldo: ${NumberFormatter.convertToMoneyLike(
                      _selectedClient?.balance ?? 0,
                    )}",
                    style: TextStyle(
                      fontWeight: .w500,
                      color: Colors.red.shade700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Card(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _selectedClient == null ? unSelectClient : selectedClient,
      ),
    );
  }
}
