import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/client_balance_display_helper.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/client_list_tile.dart';
import 'package:kardex_business/kardex_business.dart';

/// Muestra un diálogo compacto con los clientes que tienen saldo pendiente
/// (cuentas por cobrar) y retorna el cliente seleccionado, o `null` si se cierra.
Future<ClientInDb?> showPendingClientsDialog(BuildContext context) async {
  return showDialog<ClientInDb>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => const PendingClientsDialog(),
  );
}

/// Diálogo compacto que lista los clientes con saldo pendiente de cobro.
class PendingClientsDialog extends StatefulWidget {
  const PendingClientsDialog({super.key});

  @override
  State<PendingClientsDialog> createState() => _PendingClientsDialogState();
}

class _PendingClientsDialogState extends State<PendingClientsDialog> {
  static const int _maxClients = 500;

  final TextEditingController _searchController = TextEditingController();
  late Future<List<ClientInDb>> _clientsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _clientsFuture = _fetchPendingClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ClientInDb>> _fetchPendingClients() {
    final params = ClientQueryParams()..limit = _maxClients;
    return context.read<ClientsRepository>().getClientWithBalance(params);
  }

  void _reload() {
    setState(() {
      _clientsFuture = _fetchPendingClients();
    });
  }

  List<ClientInDb> _filterClients(List<ClientInDb> clients) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return clients;

    return clients.where((client) {
      return client.name.toLowerCase().contains(query) ||
          (client.cardId?.toLowerCase().contains(query) ?? false) ||
          (client.phone?.toLowerCase().contains(query) ?? false) ||
          (client.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cuentas por Cobrar",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Selecciona un cliente para ver sus facturas pendientes",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Actualizar",
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    tooltip: "Cerrar",
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar por nombre, cédula/RUC o teléfono...",
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          tooltip: "Limpiar búsqueda",
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<ClientInDb>>(
                  future: _clientsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 42,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "No se pudieron cargar las cuentas por cobrar.\n${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _reload,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Reintentar"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allClients = snapshot.data ?? const <ClientInDb>[];
                    if (allClients.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 44, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "No hay clientes con saldo pendiente",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    final filteredClients = _filterClients(allClients);
                    if (filteredClients.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 44, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "No se encontraron clientes con esa búsqueda",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredClients.length,
                      separatorBuilder: (_, _) => const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final client = filteredClients[index];
                        final balanceFormatted =
                            ClientBalanceDisplayHelper.formatBalance(client.balance);
                        final tileColor = RowColorTool.getRowColor(index);

                        return CustomClientListTile(
                          client: client,
                          backgroundColor: tileColor,
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                balanceFormatted,
                                style: TextStyle(
                                  color: client.balance > 0
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.of(context).pop(client),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
