import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'cubit/api_keys_cubit.dart';

class ApiKeysScreen extends StatelessWidget {
  const ApiKeysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = ApiKeysDataSource();
    final repo = ApiKeysRepository(ds);

    return BlocProvider(
      create: (context) => ApiKeysCubit(repo)..loadApiKeys(),
      child: const _ApiKeysScaffold(),
    );
  }
}

class _ApiKeysScaffold extends StatelessWidget {
  const _ApiKeysScaffold();

  void _showCreateDialog(BuildContext context) {
    final cubit = context.read<ApiKeysCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => _CreateApiKeyDialog(
        onSave: (name, serviceType) async {
          final createdKey = await cubit.createApiKey(
            name: name,
            serviceType: serviceType,
          );
          if (createdKey != null && context.mounted) {
            _showCreatedTokenModal(context, createdKey);
          }
        },
      ),
    );
  }

  void _showCreatedTokenModal(BuildContext context, ApiKeyModel apiKey) {
    final tokenToDisplay = apiKey.rawKey ?? apiKey.key;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Llave Creada Exitosamente"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Copia esta llave ahora. Por seguridad, no se volverá a mostrar completa:",
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                tokenToDisplay,
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text("Copiar Llave Neptuno"),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tokenToDisplay));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("¡Llave copiada al portapapeles!"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Llaves de API (Neptuno)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApiKeysCubit>().loadApiKeys(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Nueva Llave"),
      ),
      body: BlocConsumer<ApiKeysCubit, ApiKeysState>(
        listener: (context, state) {
          if (state is ApiKeysError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is ApiKeysLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApiKeysLoaded) {
            final keys = state.apiKeys;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderInfoCard(onCreateTap: () => _showCreateDialog(context)),
                  const SizedBox(height: 16),
                  if (keys.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No hay llaves de API creadas aún.\nPresiona '+ Nueva Llave' para generar una.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: keys.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),

                      itemBuilder: (context, index) {
                        final keyItem = keys[index];
                        return _ApiKeyCard(apiKey: keyItem);
                      },
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HeaderInfoCard extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _HeaderInfoCard({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.key, size: 36, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Integraciones y Llaves Neptuno (npt_live_...)",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Permite conectar Power BI, E-commerce y sistemas externos enviando la cabecera X-API-KEY.",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
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

class _ApiKeyCard extends StatelessWidget {
  final ApiKeyModel apiKey;

  const _ApiKeyCard({required this.apiKey});

  Color _getServiceBadgeColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'power_bi':
        return Colors.amber.shade800;
      case 'ecommerce':
        return Colors.blue.shade700;
      case 'accounting':
        return Colors.teal.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  String _formatServiceLabel(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'power_bi':
        return 'Power BI';
      case 'ecommerce':
        return 'E-Commerce';
      case 'accounting':
        return 'Contabilidad';
      default:
        return 'Personalizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApiKeysCubit>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: apiKey.isActive ? Colors.grey.withAlpha(80) : Colors.red.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: apiKey.isActive ? Colors.green.withAlpha(30) : Colors.grey.withAlpha(30),
              child: Icon(
                apiKey.isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
                color: apiKey.isActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          apiKey.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getServiceBadgeColor(apiKey.serviceType).withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatServiceLabel(apiKey.serviceType),
                          style: TextStyle(
                            color: _getServiceBadgeColor(apiKey.serviceType),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        apiKey.maskedKey,
                        style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: "Copiar llave enmascarada",
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: apiKey.key));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Llave copiada al portapapeles")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: apiKey.isActive,
              onChanged: (val) {
                cubit.toggleApiKeyStatus(apiKey.id, val);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Revocar Llave"),
                    content: Text("¿Seguro que deseas eliminar permanentemente la llave '${apiKey.name}'?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          cubit.deleteApiKey(apiKey.id);
                        },
                        child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateApiKeyDialog extends StatefulWidget {
  final Function(String name, String serviceType) onSave;

  const _CreateApiKeyDialog({required this.onSave});

  @override
  State<_CreateApiKeyDialog> createState() => _CreateApiKeyDialogState();
}

class _CreateApiKeyDialogState extends State<_CreateApiKeyDialog> {
  final _nameController = TextEditingController();
  String _selectedServiceType = 'power_bi';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Crear Llave Neptuno API"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre de la Llave",
                hintText: "Ej. Power BI - Tablero Gerencial",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedServiceType,
              decoration: const InputDecoration(

                labelText: "Tipo de Servicio",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'power_bi', child: Text('Power BI / Analítica')),
                DropdownMenuItem(value: 'ecommerce', child: Text('E-Commerce / Tienda Web')),
                DropdownMenuItem(value: 'accounting', child: Text('Contabilidad / ERP')),
                DropdownMenuItem(value: 'custom', child: Text('Personalizado / Terceros')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedServiceType = val);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ingresa un nombre para la llave")),
              );
              return;
            }
            Navigator.of(context).pop();
            widget.onSave(name, _selectedServiceType);
          },
          child: const Text("Generar Llave"),
        ),
      ],
    );
  }
}
