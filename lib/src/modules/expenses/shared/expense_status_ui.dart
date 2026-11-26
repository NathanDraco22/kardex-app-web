import 'package:material_ui/material_ui.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Presentación visual única para los estados de un gasto.
///
/// Centraliza etiqueta, icono y variante de color para que ambas listas
/// (operativos y proveedores) se vean exactamente igual.
class ExpenseStatusStyle {
  const ExpenseStatusStyle({
    required this.label,
    required this.icon,
    required this.variant,
  });

  final String label;
  final IconData icon;
  final AppBadgeVariant variant;
}

ExpenseStatusStyle expenseStatusStyle(ExpenseStatus status) {
  switch (status) {
    case ExpenseStatus.draft:
      return const ExpenseStatusStyle(
        label: 'Borrador',
        icon: Icons.edit_note_rounded,
        variant: AppBadgeVariant.neutral,
      );
    case ExpenseStatus.open:
      return const ExpenseStatusStyle(
        label: 'Pendiente',
        icon: Icons.schedule_rounded,
        variant: AppBadgeVariant.warning,
      );
    case ExpenseStatus.paid:
      return const ExpenseStatusStyle(
        label: 'Pagado',
        icon: Icons.check_circle_outline_rounded,
        variant: AppBadgeVariant.success,
      );
    case ExpenseStatus.partiallyPaid:
      return const ExpenseStatusStyle(
        label: 'Parcial',
        icon: Icons.timelapse_rounded,
        variant: AppBadgeVariant.info,
      );
    case ExpenseStatus.cancelled:
      return const ExpenseStatusStyle(
        label: 'Cancelado',
        icon: Icons.cancel_outlined,
        variant: AppBadgeVariant.danger,
      );
  }
}

/// Badge de estado estandarizado para gastos.
class ExpenseStatusBadge extends StatelessWidget {
  const ExpenseStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ExpenseStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = expenseStatusStyle(status);
    return AppStatusBadge(
      label: style.label,
      icon: style.icon,
      variant: style.variant,
      fontSize: compact ? 10.5 : 11.5,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    );
  }
}

/// Indica si un gasto está vencido.
///
/// Se considera vencido cuando la fecha límite ya pasó (se compara contra el
/// final del día para no marcar como vencido un gasto que vence hoy) y el
/// estado no es [ExpenseStatus.paid] ni [ExpenseStatus.cancelled].
bool isExpenseOverdue(ExpenseInDb expense, {DateTime? now}) {
  final expirationDate = expense.expirationDate;
  if (expirationDate == null) return false;
  if (expense.status == ExpenseStatus.paid || expense.status == ExpenseStatus.cancelled) {
    return false;
  }

  final dueDate = DateTime.fromMillisecondsSinceEpoch(expirationDate);
  final endOfDueDay = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59, 999);
  return endOfDueDay.isBefore(now ?? DateTime.now());
}

/// Badge compacto que resalta los gastos cuya fecha límite ya pasó.
class ExpenseOverdueBadge extends StatelessWidget {
  const ExpenseOverdueBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: 'Vencido',
      icon: Icons.warning_amber_rounded,
      variant: AppBadgeVariant.danger,
      fontSize: compact ? 10.5 : 11.5,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    );
  }
}

/// Badge compacto para señalar registros creados o editados en esta sesión.
class ExpenseActivityBadge extends StatelessWidget {
  const ExpenseActivityBadge({
    super.key,
    this.isNew = false,
    this.isUpdated = false,
    this.compact = false,
  });

  final bool isNew;
  final bool isUpdated;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!isNew && !isUpdated) return const SizedBox.shrink();

    return AppStatusBadge(
      label: isNew ? 'Nuevo' : 'Actualizado',
      icon: isNew ? Icons.auto_awesome_rounded : Icons.sync_rounded,
      variant: isNew ? AppBadgeVariant.indigo : AppBadgeVariant.teal,
      fontSize: compact ? 10.5 : 11.5,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
    );
  }
}

enum ExpenseDueUrgency { overdue, soon, normal, none }

class ExpenseDueStatus {
  const ExpenseDueStatus({
    required this.label,
    required this.urgency,
    this.daysDelta,
  });

  final String label;
  final ExpenseDueUrgency urgency;
  final int? daysDelta;
}

/// Describe el estado relativo de vencimiento respecto al día actual:
/// - `Venció hace X días` (rojo)
/// - `Vence hoy` / `Vence mañana` (ámbar)
/// - `Vence en X días` (ámbar si <= 5 días, neutro si > 5 días)
ExpenseDueStatus describeExpenseDueDate(
  int? expirationDate, {
  ExpenseStatus? status,
  DateTime? now,
}) {
  if (expirationDate == null || status == ExpenseStatus.paid || status == ExpenseStatus.cancelled) {
    return const ExpenseDueStatus(
      label: 'Sin vencimiento',
      urgency: ExpenseDueUrgency.none,
    );
  }

  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final due = DateTime.fromMillisecondsSinceEpoch(expirationDate);
  final dueDay = DateTime(due.year, due.month, due.day);
  final diffDays = dueDay.difference(today).inDays;

  if (diffDays < 0) {
    final overdueDays = -diffDays;
    return ExpenseDueStatus(
      label: overdueDays == 1 ? 'Venció hace 1 día' : 'Venció hace $overdueDays días',
      urgency: ExpenseDueUrgency.overdue,
      daysDelta: diffDays,
    );
  }
  if (diffDays == 0) {
    return const ExpenseDueStatus(
      label: 'Vence hoy',
      urgency: ExpenseDueUrgency.soon,
      daysDelta: 0,
    );
  }
  if (diffDays == 1) {
    return const ExpenseDueStatus(
      label: 'Vence mañana',
      urgency: ExpenseDueUrgency.soon,
      daysDelta: 1,
    );
  }
  return ExpenseDueStatus(
    label: 'Vence en $diffDays días',
    urgency: diffDays <= 5 ? ExpenseDueUrgency.soon : ExpenseDueUrgency.normal,
    daysDelta: diffDays,
  );
}

class ExpenseDueRelativeLabel extends StatelessWidget {
  const ExpenseDueRelativeLabel({
    super.key,
    required this.expirationDate,
    this.status,
    this.now,
    this.fontSize = 11,
  });

  final int? expirationDate;
  final ExpenseStatus? status;
  final DateTime? now;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final dueStatus = describeExpenseDueDate(expirationDate, status: status, now: now);
    if (dueStatus.urgency == ExpenseDueUrgency.none) {
      return const SizedBox.shrink();
    }

    final color = switch (dueStatus.urgency) {
      ExpenseDueUrgency.overdue => AppThemeTokens.danger,
      ExpenseDueUrgency.soon => const Color(0xFFD97706),
      ExpenseDueUrgency.normal => const Color(0xFF64748B),
      ExpenseDueUrgency.none => const Color(0xFF94A3B8),
    };

    return Text(
      dueStatus.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: dueStatus.urgency == ExpenseDueUrgency.normal ? FontWeight.w500 : FontWeight.w700,
        color: color,
      ),
    );
  }
}
