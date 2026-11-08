import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/credit_note_cubit/read_credit_notes_cubit.dart';
import 'package:kardex_app_front/src/cubits/credit_note_cubit/write_credit_notes_cubit.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/credit_note_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

import 'dialogs/create_credit_note_dialog.dart';

class CreditNotesScreen extends StatelessWidget {
  const CreditNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<CreditNotesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadCreditNoteCubit(repository)..getAll(),
        ),
        BlocProvider(
          create: (context) => WriteCreditNoteCubit(repository),
        ),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Notas de Crédito",
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        actions: [
          IconButton(
            tooltip: "Recargar",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ReadCreditNoteCubit>().getAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppThemeTokens.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () => showCreateCreditNoteDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Nueva Nota",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String _searchQuery = "";
  CreditNoteType? _filterType;
  CreditNoteStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            // --- BARRA DE BÚSQUEDA Y FILTROS ---
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppThemeTokens.borderRadiusLg,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppThemeTokens.subtleCardShadow(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar por folio, cliente o factura...",
                      hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => setState(() => _searchQuery = ""),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppThemeTokens.borderRadiusMd,
                        borderSide: const BorderSide(color: AppThemeTokens.indigo, width: 1.5),
                      ),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill(
                          label: "Todos los Tipos",
                          isSelected: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: "Por Devolución",
                          isSelected: _filterType == CreditNoteType.devolution,
                          accentColor: AppThemeTokens.indigo,
                          onTap: () => setState(() => _filterType = _filterType == CreditNoteType.devolution ? null : CreditNoteType.devolution),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: "Por Monto",
                          isSelected: _filterType == CreditNoteType.amount,
                          accentColor: AppThemeTokens.teal,
                          onTap: () => setState(() => _filterType = _filterType == CreditNoteType.amount ? null : CreditNoteType.amount),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(width: 1, height: 18, color: const Color(0xFFCBD5E1)),
                        ),
                        _buildFilterPill(
                          label: "Todos los Estados",
                          isSelected: _filterStatus == null,
                          onTap: () => setState(() => _filterStatus = null),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: "Confirmadas",
                          isSelected: _filterStatus == CreditNoteStatus.confirmed,
                          accentColor: AppThemeTokens.warning,
                          onTap: () => setState(() => _filterStatus = _filterStatus == CreditNoteStatus.confirmed ? null : CreditNoteStatus.confirmed),
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: "Aplicadas",
                          isSelected: _filterStatus == CreditNoteStatus.applied,
                          accentColor: AppThemeTokens.success,
                          onTap: () => setState(() => _filterStatus = _filterStatus == CreditNoteStatus.applied ? null : CreditNoteStatus.applied),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- LISTADO DE NOTAS DE CRÉDITO ---
            Expanded(
              child: BlocBuilder<ReadCreditNoteCubit, ReadCreditNoteState>(
                builder: (context, state) {
                  if (state is ReadCreditNoteLoading || state is ReadCreditNoteInitial) {
                    return AppSkeletonLoader.listTile(count: 6);
                  }

                  if (state is ReadCreditNoteError) {
                    return AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: "Error al cargar notas de crédito",
                      subtitle: state.message,
                      accentColor: AppThemeTokens.danger,
                      actionLabel: "Reintentar",
                      actionIcon: Icons.refresh_rounded,
                      onAction: () => context.read<ReadCreditNoteCubit>().getAll(),
                    );
                  }

                  state as ReadCreditNoteSuccess;
                  final allItems = state.items;

                  // Filtrado en memoria
                  final filtered = allItems.where((item) {
                    if (_filterType != null && item.type != _filterType) return false;
                    if (_filterStatus != null && item.status != _filterStatus) return false;
                    if (_searchQuery.isNotEmpty) {
                      final matchDoc = item.docNumber.toLowerCase().contains(_searchQuery);
                      final matchClient = item.clientInfo.name.toLowerCase().contains(_searchQuery);
                      final matchOrig = item.originalInvoiceDocNumber.toLowerCase().contains(_searchQuery);
                      if (!matchDoc && !matchClient && !matchOrig) return false;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    if (allItems.isEmpty) {
                      return AppEmptyState(
                        icon: FluentIcons.document_bullet_list_24_regular,
                        title: "No hay notas de crédito registradas",
                        subtitle: "Emite tu primera nota de crédito por devolución de productos o por ajuste directo de monto.",
                        accentColor: AppThemeTokens.indigo,
                        actionLabel: "Nueva Nota de Crédito",
                        actionIcon: Icons.add_rounded,
                        onAction: () => showCreateCreditNoteDialog(context),
                      );
                    }

                    return AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: "Sin resultados de búsqueda",
                      subtitle: "No encontramos notas que coincidan con los filtros y término especificados.",
                      accentColor: AppThemeTokens.indigo,
                      actionLabel: "Restablecer filtros",
                      actionIcon: Icons.refresh_rounded,
                      onAction: () {
                        setState(() {
                          _searchQuery = "";
                          _filterType = null;
                          _filterStatus = null;
                        });
                      },
                    );
                  }

                  return Column(
                    children: [
                      if (state is ReadCreditNoteRefreshing)
                        const LinearProgressIndicator(minHeight: 2),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => context.read<ReadCreditNoteCubit>().getAll(),
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 84, top: 6, left: 16, right: 16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return _CreditNoteItemCard(
                                item: item,
                                onTap: () => showCreditNoteViewerDialog(context, item),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final effectiveColor = accentColor ?? AppThemeTokens.indigo;

    return InkWell(
      onTap: onTap,
      borderRadius: AppThemeTokens.borderRadiusFull,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: AppThemeTokens.borderRadiusFull,
          border: Border.all(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.45)
                : const Color(0xFFCBD5E1),
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? effectiveColor : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _CreditNoteItemCard extends StatefulWidget {
  final CreditNoteInDb item;
  final VoidCallback onTap;

  const _CreditNoteItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  State<_CreditNoteItemCard> createState() => _CreditNoteItemCardState();
}

class _CreditNoteItemCardState extends State<_CreditNoteItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDevolution = item.type == CreditNoteType.devolution;
    final accent = isDevolution ? AppThemeTokens.indigo : AppThemeTokens.teal;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.008 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppThemeTokens.borderRadiusMd,
            border: Border.all(
              color: _isHovered
                  ? accent.withValues(alpha: 0.45)
                  : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.2 : 1.0,
            ),
            boxShadow: _isHovered
                ? AppThemeTokens.hoverCardShadow(accent: accent)
                : AppThemeTokens.subtleCardShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppThemeTokens.borderRadiusMd,
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Avatar con Icono Semántico
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: AppThemeTokens.borderRadiusSm,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.25),
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        isDevolution
                            ? Icons.assignment_return_rounded
                            : Icons.monetization_on_rounded,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Detalles de la Nota
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NC #${item.docNumber}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.clientInfo.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                DateTimeTool.formatddMMyy(item.createdAt),
                                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                              ),
                              if (isDevolution && item.originalInvoiceDocNumber.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Icon(Icons.receipt_long_rounded, size: 12, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Factura #${item.originalInvoiceDocNumber}",
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          // ÚLTIMA ROW: Badges con Wrap anti-overflow
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (isDevolution)
                                AppStatusBadge.indigo(
                                  label: item.type.display,
                                  icon: Icons.undo_rounded,
                                )
                              else
                                AppStatusBadge.teal(
                                  label: item.type.display,
                                  icon: Icons.attach_money_rounded,
                                ),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Monto y Flecha
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormatter.convertToMoneyLike(item.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: accent,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              transform: Matrix4.translationValues(_isHovered ? 2.0 : 0.0, 0, 0),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: _isHovered ? accent : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CreditNoteStatus status) {
    switch (status) {
      case CreditNoteStatus.applied:
        return AppStatusBadge.success(
          label: status.display,
          icon: Icons.check_circle_outline_rounded,
        );
      case CreditNoteStatus.confirmed:
        return AppStatusBadge.warning(
          label: status.display,
          icon: Icons.access_time_rounded,
        );
      case CreditNoteStatus.cancelled:
        return AppStatusBadge.danger(
          label: status.display,
          icon: Icons.cancel_outlined,
        );
      case CreditNoteStatus.open:
        return AppStatusBadge.info(
          label: status.display,
          icon: Icons.pending_actions_rounded,
        );
    }
  }
}
