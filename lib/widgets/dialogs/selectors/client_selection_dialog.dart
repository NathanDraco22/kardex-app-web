import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
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
  bool _hasSearched = false;
  String? _errorMessage;
  int _searchRequestId = 0;

  Future<void> _searchClients(String keyword) async {
    if (!mounted) return;

    final requestId = ++_searchRequestId;

    if (keyword.trim().isEmpty) {
      setState(() {
        _clients = [];
        _isLoading = false;
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final clientsRepo = context.read<ClientsRepository>();
      final clients = await clientsRepo.searchClientByKeyword(keyword);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialogHeight = (MediaQuery.sizeOf(context).height * 0.68).clamp(320.0, 620.0).toDouble();

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: Text("Buscar Cliente")),
          IconButton(
            tooltip: "Cerrar",
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: 540,
        height: dialogHeight,
        child: Column(
          children: [
            SearchFieldDebounced(
              autoFocus: true,
              hintText: "Nombre, cédula, teléfono o código",
              onSearch: _searchClients,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text("Error: $_errorMessage"));
    }

    if (!_hasSearched) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Ingresa nombre, cédula, teléfono o código para buscar.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_clients.isEmpty) {
      return const Center(child: Text("No se encontraron clientes"));
    }

    return ListView.separated(
      itemCount: _clients.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final client = _clients[index];
        return _ClientResultTile(
          client: client,
          onTap: () => Navigator.pop(context, client),
        );
      },
    );
  }
}

class _ClientResultTile extends StatelessWidget {
  const _ClientResultTile({
    required this.client,
    required this.onTap,
  });

  final ClientInDb client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardId = client.cardId?.trim();
    final cardIdText = cardId == null || cardId.isEmpty ? "No registrada" : cardId;
    final groupText = client.group.trim();
    final locationText = [
      client.location,
      client.address,
    ].where((value) => value != null && value.trim().isNotEmpty).map((value) => value!.trim()).join(" • ");
    final phoneText = client.phone?.trim() ?? "";
    final initial = client.name.trim().isEmpty ? "?" : client.name.trim().substring(0, 1).toUpperCase();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              child: Text(initial),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "#${client.id}  •  Cédula: $cardIdText",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (groupText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Grupo: $groupText",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (locationText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      locationText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (phoneText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Tel: $phoneText",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      NumberFormatter.convertToMoneyLike(client.balance),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: client.balance > 0 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.isActive ? "Activo" : "Inactivo",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: client.isActive ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
