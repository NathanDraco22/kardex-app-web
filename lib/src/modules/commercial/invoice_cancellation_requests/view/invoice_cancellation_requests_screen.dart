import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/read_invoice_cancellation_requests_cubit.dart';
import '../cubit/read_invoice_cancellation_requests_state.dart';
import '../cubit/write_invoice_cancellation_requests_cubit.dart';
import '../cubit/write_invoice_cancellation_requests_state.dart';

class InvoiceCancellationRequestsScreen extends StatelessWidget {
  const InvoiceCancellationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<InvoiceCancellationRequestsRepository>();
    final authState = getIt<AuthCubit>().state;
    final branchId = authState is Authenticated ? authState.branch.id : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadInvoiceCancellationRequestsCubit(repo)
            ..loadRequests(branchId: branchId),
        ),
        BlocProvider(
          create: (_) => WriteInvoiceCancellationRequestsCubit(repo),
        ),
      ],
      child: const _InvoiceCancellationRequestsView(),
    );
  }
}

class _InvoiceCancellationRequestsView extends StatelessWidget {
  const _InvoiceCancellationRequestsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteInvoiceCancellationRequestsCubit,
        WriteInvoiceCancellationRequestsState>(
      listener: (context, state) {
        if (state is WriteInvoiceCancellationRequestsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is WriteInvoiceCancellationRequestsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Solicitudes de Anulación'),
          actions: [
            IconButton(
              tooltip: 'Recargar',
              onPressed: () {
                context
                    .read<ReadInvoiceCancellationRequestsCubit>()
                    .loadRequests();
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            const _StatusFilterBar(),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<ReadInvoiceCancellationRequestsCubit,
                  ReadInvoiceCancellationRequestsState>(
                builder: (context, state) {
                  if (state is ReadInvoiceCancellationRequestsLoading ||
                      state is ReadInvoiceCancellationRequestsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ReadInvoiceCancellationRequestsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(state.message),
                      ),
                    );
                  }
                  final items =
                      (state as ReadInvoiceCancellationRequestsSuccess).requests;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay solicitudes de anulación en este filtro.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CancellationRequestCard(request: items[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadInvoiceCancellationRequestsCubit>();
    final current = cubit.statusFilter;

    Widget chip(String label, InvoiceCancellationRequestStatus? status) {
      final selected = current == status;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => cubit.loadRequests(
          status: status,
          updateStatusFilter: true,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          chip('Pendientes', InvoiceCancellationRequestStatus.pending),
          const SizedBox(width: 8),
          chip('Aprobadas', InvoiceCancellationRequestStatus.approved),
          const SizedBox(width: 8),
          chip('Rechazadas', InvoiceCancellationRequestStatus.rejected),
          const SizedBox(width: 8),
          chip('Canceladas', InvoiceCancellationRequestStatus.cancelled),
          const SizedBox(width: 8),
          chip('Todas', null),
        ],
      ),
    );
  }
}

class _CancellationRequestCard extends StatelessWidget {
  final InvoiceCancellationRequestInDb request;

  const _CancellationRequestCard({required this.request});

  Color _statusColor() => switch (request.status) {
        InvoiceCancellationRequestStatus.pending => AppThemeTokens.warning,
        InvoiceCancellationRequestStatus.approved => AppThemeTokens.success,
        InvoiceCancellationRequestStatus.rejected => AppThemeTokens.danger,
        InvoiceCancellationRequestStatus.cancelled => const Color(0xFF64748B),
      };

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    final currentUser = authState is Authenticated ? authState.session.user : null;
    final isRequester = currentUser?.id == request.requestedBy.id;
    final isApprover = currentUser != null &&
        AccessManager().hasAccessTo(
          currentUser,
          CommercialSubModules.approveInvoiceCancellation.name,
        );
    final isWriting = context.watch<WriteInvoiceCancellationRequestsCubit>().state
        is WriteInvoiceCancellationRequestsLoading;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Solicitud #${request.docNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status.display,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  NumberFormatter.convertToMoneyLike(request.invoiceTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                InkWell(
                  onTap: () => showInvoiceViewerDialogFromId(
                    context,
                    request.invoiceId,
                  ),
                  child: Text(
                    'Factura #${request.invoiceDocNumber} (ver)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text('Cliente: ${request.clientInfo.name}'),
                Text('Pago: ${request.invoicePaymentType.typeLabel}'),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Solicitado por: ${request.requestedBy.name} • ${DateTimeTool.formatddMMyy(request.createdAt)} ${DateTimeTool.formatHHmm(request.createdAt)}',
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 4),
            Text(
              'Motivo: ${request.reason}',
              style: const TextStyle(fontSize: 13.5),
            ),
            if (request.reviewedBy != null) ...[
              const SizedBox(height: 4),
              Text(
                'Revisado por: ${request.reviewedBy!.name}${request.reviewNotes != null && request.reviewNotes!.isNotEmpty ? " • ${request.reviewNotes}" : ""}',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
              ),
            ],
            if (request.status == InvoiceCancellationRequestStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isRequester || isApprover)
                    TextButton(
                      onPressed: isWriting || currentUser == null
                          ? null
                          : () => context
                              .read<WriteInvoiceCancellationRequestsCubit>()
                              .cancelRequest(
                                request.id,
                                UserInfo(id: currentUser.id, name: currentUser.username),
                              ),
                      child: const Text('Cancelar solicitud'),
                    ),
                  const SizedBox(width: 8),
                  Gate(
                    filters: const [
                      RolePermissionGateFilter(
                        permissions: [
                          CommercialSubModules.approveInvoiceCancellation,
                        ],
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: isWriting || currentUser == null
                              ? null
                              : () => _showRejectDialog(
                                    context,
                                    UserInfo(
                                      id: currentUser.id,
                                      name: currentUser.username,
                                    ),
                                  ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppThemeTokens.danger,
                          ),
                          child: const Text('Rechazar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isWriting || currentUser == null
                              ? null
                              : () => _showApproveDialog(
                                    context,
                                    UserInfo(
                                      id: currentUser.id,
                                      name: currentUser.username,
                                    ),
                                  ),
                          child: const Text('Aprobar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showApproveDialog(BuildContext context, UserInfo reviewer) async {
    final notesController = TextEditingController();
    final writeCubit = context.read<WriteInvoiceCancellationRequestsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Aprobar anulación #${request.invoiceDocNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Al aprobar, la factura quedará anulada y su inventario (y saldo de crédito si aplica) se revertirá automáticamente.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmar anulación'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await writeCubit.approveRequest(
        request.id,
        reviewer,
        reviewNotes: notesController.text.trim(),
      );
    }
    notesController.dispose();
  }

  Future<void> _showRejectDialog(BuildContext context, UserInfo reviewer) async {
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final writeCubit = context.read<WriteInvoiceCancellationRequestsCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rechazar solicitud #${request.docNumber}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: notesController,
            maxLines: 2,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Motivo de rechazo *',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().length < 3) {
                return 'Ingresa un motivo de al menos 3 caracteres.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await writeCubit.rejectRequest(
        request.id,
        reviewer,
        reviewNotes: notesController.text.trim(),
      );
    }
    notesController.dispose();
  }
}
