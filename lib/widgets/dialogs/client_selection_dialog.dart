import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<ClientInDb?> showClientSelectionDialog(BuildContext context) async {
  return await showDialog<ClientInDb?>(
    context: context,
    builder: (context) => const ClientSelectionDialog(),
  );
}

class ClientSelectionDialog extends StatefulWidget {
  const ClientSelectionDialog({super.key});

  @override
  State<ClientSelectionDialog> createState() => _ClientSelectionDialogState();
}

class _ClientSelectionDialogState extends State<ClientSelectionDialog> {
  List<ClientInDb> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchClients(String keyword) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (keyword.isEmpty) {
      setState(() {
        _clients = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final clientsRepo = context.read<ClientsRepository>();
      final clients = await clientsRepo.searchClientByKeyword(keyword);
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleccionar Cliente"),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            SearchFieldDebounced(
              autoFocus: true,
              onSearch: _searchClients,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text("Error: $_errorMessage"));
    }

    if (_clients.isEmpty) {
      return const Center(child: Text("No se encontraron clientes"));
    }

    return ListView.separated(
      itemCount: _clients.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final client = _clients[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(client.name.isNotEmpty ? client.name.substring(0, 1).toUpperCase() : "?"),
          ),
          title: Text(client.name),
          subtitle: Row(
            children: [
              Text(client.location ?? ""),
              const Text(" | "),
              Text(client.group),
            ],
          ),
          onTap: () {
            Navigator.pop(context, client);
          },
        );
      },
    );
  }
}
