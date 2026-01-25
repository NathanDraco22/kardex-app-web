import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/integrations_repository.dart';
import 'package:kardex_app_front/src/modules/settings/view/integrations/cubit/read_integrations_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/integrations/cubit/write_integration_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/integrations/dialog/edit_integration_dialog.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final integrationsRepo = context.read<IntegrationsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadIntegrationsCubit(integrationsRepo)..loadAllIntegrations(),
        ),
        BlocProvider(
          create: (context) => WriteIntegrationCubit(integrationsRepo),
        ),
      ],
      child: const _Scaffold(),
    );
  }
}

class _Scaffold extends StatelessWidget {
  const _Scaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Integraciones"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteIntegrationCubit, WriteIntegrationState>(
      listener: (context, state) {
        if (state is WriteIntegrationLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        } else {
          LoadingDialogManager.closeLoadingDialog(context);
        }

        if (state is WriteIntegrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<ReadIntegrationsCubit>().loadAllIntegrations();
        }
        if (state is WriteIntegrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<ReadIntegrationsCubit, ReadIntegrationsState>(
        builder: (context, state) {
          if (state is ReadIntegrationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReadIntegrationsError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is ReadIntegrationsLoaded) {
            final integrations = state.integrations;
            if (integrations.isEmpty) {
              return const Center(child: Text("No hay integraciones disponibles"));
            }

            final integration = integrations.first;
            final telegram = integration.telegram;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Telegram",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => EditIntegrationDialog(
                                      integration: integration,
                                      onSave: (update) {
                                        context.read<WriteIntegrationCubit>().updateIntegration(
                                          integration.id,
                                          update,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: "Estado",
                            value: telegram.isActive ? "Activo" : "Inactivo",
                            icon: telegram.isActive ? Icons.check_circle : Icons.cancel,
                            color: telegram.isActive ? Colors.green : Colors.grey,
                          ),
                          const Divider(),
                          _InfoRow(
                            label: "Report ID",
                            value: telegram.reportId,
                            icon: Icons.description,
                          ),
                          const Divider(),
                          _InfoRow(
                            label: "Adjustment ID",
                            value: telegram.adjustmentId,
                            icon: Icons.tune,
                          ),
                          const Divider(),
                          const _TestButton(),
                        ],
                      ),
                    ),
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

class _TestButton extends StatelessWidget {
  const _TestButton();

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return SizedBox(
          width: 120,
          child: ElevatedButton(
            onPressed: () async {
              if (isLoading) return;
              setState(() {
                isLoading = true;
              });

              try {
                await context.read<IntegrationsRepository>().sendTelegramTestNotification();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
              setState(() {
                isLoading = false;
              });
            },
            child: isLoading ? const LinearProgressIndicator() : const Text("Enviar Prueba"),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value.isEmpty ? "No configurado" : value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
