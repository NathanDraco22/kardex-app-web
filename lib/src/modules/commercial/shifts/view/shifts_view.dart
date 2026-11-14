import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/read_shifts_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/cubit/read_shifts_state.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/dialogs/shift_viewer_dialog.dart';
import 'package:kardex_app_front/src/modules/commercial/shifts/widgets/shift_status_button.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';
import 'package:kardex_business/kardex_business.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  ShiftStatus? _statusFilter;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final branchId = getIt<AuthCubit>().currentBranchId;
    final repo = context.read<ShiftsRepository>();

    return BlocProvider(
      create: (_) => ReadShiftsCubit(shiftsRepository: repo)
        ..loadShifts(ShiftQueryParams(branchId: branchId)),
      child: Builder(
        builder: (context) {
          void reload() {
            context.read<ReadShiftsCubit>().loadShifts(
                  ShiftQueryParams(
                    branchId: branchId,
                    status: _statusFilter,
                    startDate: _dateRange?.start.millisecondsSinceEpoch,
                    endDate: _dateRange != null
                        ? DateTime(
                            _dateRange!.end.year,
                            _dateRange!.end.month,
                            _dateRange!.end.day,
                            23,
                            59,
                            59,
                            999,
                          ).millisecondsSinceEpoch
                        : null,
                  ),
                );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Control de Turnos y Caja'),
              actions: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ShiftStatusButton(compact: true),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: reload,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: Column(
              children: [
                _buildFiltersBar(context, reload),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<ReadShiftsCubit, ReadShiftsState>(
                    builder: (context, state) {
                      if (state is ReadShiftsLoading || state is ReadShiftsInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is ReadShiftsError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      if (state is ReadShiftsLoaded) {
                        if (state.shifts.isEmpty) {
                          return const Center(
                            child: Text(
                              'No hay turnos registrados con los filtros actuales.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.shifts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final shift = state.shifts[index];
                            return _ShiftCard(
                              shift: shift,
                              onTap: () => ShiftViewerDialog.show(
                                context,
                                shift: shift,
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersBar(BuildContext context, VoidCallback reload) {
    final dateFmt = DateFormat('dd/MM/yy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFF8FAFC),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: _statusFilter == null,
            onSelected: (_) {
              setState(() => _statusFilter = null);
              reload();
            },
          ),
          ChoiceChip(
            label: const Text('Abiertos'),
            selected: _statusFilter == ShiftStatus.open,
            onSelected: (_) {
              setState(() => _statusFilter = ShiftStatus.open);
              reload();
            },
          ),
          ChoiceChip(
            label: const Text('Cerrados'),
            selected: _statusFilter == ShiftStatus.closed,
            onSelected: (_) {
              setState(() => _statusFilter = ShiftStatus.closed);
              reload();
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now().add(const Duration(days: 1)),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
                reload();
              }
            },
            icon: const Icon(Icons.date_range_rounded, size: 18),
            label: Text(
              _dateRange == null
                  ? 'Filtrar por fecha'
                  : '${dateFmt.format(_dateRange!.start)} - ${dateFmt.format(_dateRange!.end)}',
            ),
          ),
          if (_dateRange != null)
            IconButton(
              tooltip: 'Limpiar fecha',
              onPressed: () {
                setState(() => _dateRange = null);
                reload();
              },
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final ShiftInDb shift;
  final VoidCallback onTap;

  const _ShiftCard({required this.shift, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOpen = shift.status == ShiftStatus.open;
    final dateFmt = DateFormat('dd/MM/yyyy hh:mm a');
    final openedAt = DateTime.fromMillisecondsSinceEpoch(shift.openedAt);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOpen
                  ? AppThemeTokens.success.withValues(alpha: 0.45)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isOpen ? AppThemeTokens.success : AppThemeTokens.indigo)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.point_of_sale_rounded,
                  color: isOpen ? AppThemeTokens.success : AppThemeTokens.indigo,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Turno #${shift.docNumber}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (isOpen ? AppThemeTokens.success : const Color(0xFF64748B))
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            shift.status.display,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isOpen ? AppThemeTokens.success : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Cajero: ${shift.openedBy.name} • Apertura: ${dateFmt.format(openedAt)}',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 14,
                      children: [
                        Text(
                          'Fondo: ${NumberFormatter.convertToMoneyLike(shift.initialCash)}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        if (!isOpen) ...[
                          Text(
                            'Contado: ${NumberFormatter.convertToMoneyLike(shift.countedCash)}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Total: ${NumberFormatter.convertToMoneyLike(shift.grandTotal)}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppThemeTokens.indigo,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
