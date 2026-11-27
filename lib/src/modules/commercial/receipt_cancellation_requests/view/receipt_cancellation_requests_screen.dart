import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/read_receipt_cancellation_requests_cubit.dart';
import '../cubit/read_receipt_cancellation_requests_state.dart';
import '../cubit/write_receipt_cancellation_requests_cubit.dart';
import '../cubit/write_receipt_cancellation_requests_state.dart';

class ReceiptCancellationRequestsScreen extends StatelessWidget {
  const ReceiptCancellationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReceiptCancellationRequestsRepository>();
    final authState = getIt<AuthCubit>().state;
    final branchId = authState is Authenticated ? authState.branch.id : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadReceiptCancellationRequestsCubit(repo)
            ..loadRequests(branchId: branchId),
        ),
        BlocProvider(
          create: (_) => WriteReceiptCancellationRequestsCubit(repo),
        ),
      ],
      child: const _ReceiptCancellationRequestsView(),
    );
  }
}

class _ReceiptCancellationRequestsView extends StatelessWidget {
  const _ReceiptCancellationRequestsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteReceiptCancellationRequestsCubit,
        WriteReceiptCancellationRequestsState>(
      listener: (context, state) {
        if (state is WriteReceiptCancellationRequestsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is WriteReceiptCancellationRequestsError) {
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
          title: const Text('Solicitudes de Anulación de Recibos'),
          actions: [
            IconButton(
              tooltip: 'Recargar',
              onPressed: () {
                context
                    .read<ReadReceiptCancellationRequestsCubit>()
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
              child: BlocBuilder<ReadReceiptCancellationRequestsCubit,
                  ReadReceiptCancellationRequestsState>(
                builder: (context, state) {
                  if (state is ReadReceiptCancellationRequestsLoading ||
                      state is ReadReceiptCancellationRequestsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ReadReceiptCancellationRequestsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(state.message),
                      ),
                    );
                  }
                  final items =
                      (state as ReadReceiptCancellationRequestsSuccess).requests;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay solicitudes de anulación de recibos en este filtro.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _ReceiptCancellationRequestCard(
                        request: items[index],
                      );
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
    final cubit = context.watch<ReadReceiptCancellationRequestsCubit>();
    final current = cubit.statusFilter;

    Widget chip(String label, ReceiptCancellationRequestStatus? status) {
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
          chip('Pendientes', ReceiptCancellationRequestStatus.pending),
          const SizedBox(width: 8),
          chip('Aprobadas', ReceiptCancellationRequestStatus.approved),
          const SizedBox(width: 8),
          chip('Rechazadas', ReceiptCancellationRequestStatus.rejected),
          const SizedBox(width: 8),
          chip('Canceladas', ReceiptCancellationRequestStatus.cancelled),
          const SizedBox(width: 8),
          chip('Todas', null),
        ],
      ),
    );
  }
}

class _ReceiptCancellationRequestCard extends StatelessWidget {
  final ReceiptCancellationRequestInDb request;

  const _ReceiptCancellationRequestCard({required this.request});

  Color _statusColor() => switch (request.status) {
        ReceiptCancellationRequestStatus.pending => AppThemeTokens.warning,
        ReceiptCancellationRequestStatus.approved => AppThemeTokens.success,
        ReceiptCancellationRequestStatus.rejected => AppThemeTokens.danger,
        ReceiptCancellationRequestStatus.cancelled => const Color(0xFF64748B),
      };

  String _paymentMethodLabel(PaymentMethod method) => switch (method) {
        PaymentMethod.cash => 'Efectivo',
        PaymentMethod.transfer => 'Transferencia',
        PaymentMethod.card => 'Tarjeta',
        PaymentMethod.check => 'Cheque',
        PaymentMethod.other => 'Otro',
      };

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    final currentUser = authState is Authenticated ? authState.session.user : null;
    final isRequester = currentUser?.id == request.requestedBy.id;
    final isApprover = currentUser != null &&
        AccessManager().hasAccessTo(
          currentUser,
          CommercialSubModules.approveReceiptCancellation.name,
        );
    final isWriting = context.watch<WriteReceiptCancellationRequestsCubit>().state
        is WriteReceiptCancellationRequestsLoading;

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
                  NumberFormatter.convertToMoneyLike(request.receiptTotal),
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
                  onTap: () => showReceiptViewerDialogFromDocNumber(
                    context,
                    request.receiptDocNumber,
                  ),
                  child: Text(
                    'Recibo #${request.receiptDocNumber} (ver)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text('Cliente: ${request.clientInfo.name}'),
                Text('Método: ${_paymentMethodLabel(request.receiptPaymentMethod)}'),
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
            if (request.status == ReceiptCancellationRequestStatus.pending) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isRequester || isApprover)
                      TextButton(
                        onPressed: isWriting || currentUser == null
                            ? null
                            : () => context
                                .read<WriteReceiptCancellationRequestsCubit>()
                                .cancelRequest(
                                  request.id,
                                  UserInfo(
                                    id: currentUser.id,
                                    name: currentUser.username,
                                  ),
                                ),
                        child: const Text('Cancelar solicitud'),
                      ),
                    Gate(
                      filters: const [
                        RolePermissionGateFilter(
                          permissions: [
                            CommercialSubModules.approveReceiptCancellation,
                          ],
                        ),
                      ],
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showApproveDialog(BuildContext context, UserInfo reviewer) async {
    final writeCubit = context.read<WriteReceiptCancellationRequestsCubit>();
    final notes = await showDialog<String>(
      context: context,
      builder: (_) => _ApproveReceiptDialog(docNumber: request.receiptDocNumber),
    );
    if (notes != null) {
      await writeCubit.approveRequest(
        request.id,
        reviewer,
        reviewNotes: notes,
      );
    }
  }

  Future<void> _showRejectDialog(BuildContext context, UserInfo reviewer) async {
    final writeCubit = context.read<WriteReceiptCancellationRequestsCubit>();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _RejectReceiptDialog(docNumber: request.docNumber),
    );
    if (reason != null) {
      await writeCubit.rejectRequest(
        request.id,
        reviewer,
        reviewNotes: reason,
      );
    }
  }
}

class _ApproveReceiptDialog extends StatefulWidget {
  final String docNumber;
  const _ApproveReceiptDialog({required this.docNumber});

  @override
  State<_ApproveReceiptDialog> createState() => _ApproveReceiptDialogState();
}

class _ApproveReceiptDialogState extends State<_ApproveReceiptDialog> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Aprobar anulación de recibo #${widget.docNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Al aprobar, el recibo quedará anulado y se revertirán los abonos aplicados en sus facturas y el saldo del cliente.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_notesController.text.trim()),
          child: const Text('Confirmar anulación'),
        ),
      ],
    );
  }
}

class _RejectReceiptDialog extends StatefulWidget {
  final String docNumber;
  const _RejectReceiptDialog({required this.docNumber});

  @override
  State<_RejectReceiptDialog> createState() => _RejectReceiptDialogState();
}

class _RejectReceiptDialogState extends State<_RejectReceiptDialog> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rechazar solicitud #${widget.docNumber}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _notesController,
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
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_notesController.text.trim());
            }
          },
          child: const Text('Rechazar'),
        ),
      ],
    );
  }
}
