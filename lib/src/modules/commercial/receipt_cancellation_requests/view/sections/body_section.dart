part of '../receipt_cancellation_requests_screen.dart';

class _BodySection extends StatelessWidget {
  const _BodySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadReceiptCancellationRequestsCubit,
        ReadReceiptCancellationRequestsState>(
      builder: (context, state) {
        if (state is ReadReceiptCancellationRequestsLoading ||
            state is ReadReceiptCancellationRequestsInitial) {
          return const Card(
            margin: EdgeInsets.zero,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReadReceiptCancellationRequestsError) {
          return Card(
            margin: EdgeInsets.zero,
            child: AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'No se pudieron cargar las solicitudes',
              subtitle: state.message,
              accentColor: AppThemeTokens.danger,
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: () => context
                  .read<ReadReceiptCancellationRequestsCubit>()
                  .loadRequests(),
            ),
          );
        }

        final items =
            (state as ReadReceiptCancellationRequestsSuccess).requests;
        final totalAmount = items.fold<int>(
          0,
          (sum, request) => sum + request.receiptTotal,
        );

        return Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? AppEmptyState(
                        icon: Icons.receipt_outlined,
                        title: 'No hay solicitudes de anulación de recibos',
                        subtitle:
                            'Abre el historial de recibos y solicita la anulación desde el visor de un recibo.',
                        accentColor: AppThemeTokens.indigo,
                        actionLabel: 'Nueva solicitud de anulación',
                        actionIcon: Icons.add_rounded,
                        onAction: () =>
                            context.pushNamed(RouteNames.receiptHistory),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _ReceiptCancellationRequestRow(
                            request: items[index],
                            index: index,
                            showDivider: index < items.length - 1,
                          );
                        },
                      ),
              ),
              const Divider(height: 1),
              _TableFooter(
                itemCount: items.length,
                totalAmount: totalAmount,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({
    required this.itemCount,
    required this.totalAmount,
  });

  final int itemCount;
  final int totalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Text(
            'Total Solicitudes: $itemCount',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const Spacer(),
          const Text(
            'Total Recibos: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            NumberFormatter.convertToMoneyLike(totalAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppThemeTokens.indigo,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCancellationRequestRow extends StatelessWidget {
  final ReceiptCancellationRequestInDb request;
  final int index;
  final bool showDivider;

  const _ReceiptCancellationRequestRow({
    required this.request,
    required this.index,
    required this.showDivider,
  });

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
    final currentUser =
        authState is Authenticated ? authState.session.user : null;
    final isRequester = currentUser?.id == request.requestedBy.id;
    final isApprover = currentUser != null &&
        AccessManager().hasAccessTo(
          currentUser,
          CommercialSubModules.approveReceiptCancellation.name,
        );
    final isWriting = context
        .watch<WriteReceiptCancellationRequestsCubit>()
        .state is WriteReceiptCancellationRequestsLoading;

    return ColoredBox(
      color: RowColorTool.getRowColor(index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
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
                    Text(
                      'Método: ${_paymentMethodLabel(request.receiptPaymentMethod)}',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Solicitado por: ${request.requestedBy.name} • ${DateTimeTool.formatddMMyy(request.createdAt)} ${DateTimeTool.formatHHmm(request.createdAt)}',
                  style:
                      const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
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
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
                if (request.status ==
                    ReceiptCancellationRequestStatus.pending) ...[
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
                                    .read<
                                        WriteReceiptCancellationRequestsCubit>()
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
          if (showDivider)
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
        ],
      ),
    );
  }

  Future<void> _showApproveDialog(
    BuildContext context,
    UserInfo reviewer,
  ) async {
    final writeCubit = context.read<WriteReceiptCancellationRequestsCubit>();
    final notes = await showDialog<String>(
      context: context,
      builder: (_) =>
          _ApproveReceiptDialog(docNumber: request.receiptDocNumber),
    );
    if (notes != null) {
      await writeCubit.approveRequest(
        request.id,
        reviewer,
        reviewNotes: notes,
      );
    }
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    UserInfo reviewer,
  ) async {
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
          onPressed: () =>
              Navigator.of(context).pop(_notesController.text.trim()),
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
