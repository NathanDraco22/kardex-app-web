import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kardex_app_front/src/modules/expenses/shared/expense_form_utils.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';

/// Decoración compartida para los campos de los formularios de gastos.
InputDecoration expenseFormFieldDecoration({
  required String label,
  String? hint,
  bool alignLabelWithHint = false,
  Color accentColor = AppThemeTokens.indigo,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? prefixText,
  String? helperText,
}) {
  final border = OutlineInputBorder(
    borderRadius: AppThemeTokens.borderRadiusMd,
    borderSide: const BorderSide(color: AppThemeTokens.borderLight),
  );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint: alignLabelWithHint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixText: prefixText,
    helperText: helperText,
    helperMaxLines: 2,
    helperStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
    prefixStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF334155),
    ),
    labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
    floatingLabelStyle: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: accentColor,
    ),
    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: border,
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: BorderSide(color: accentColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: const BorderSide(color: AppThemeTokens.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: const BorderSide(color: AppThemeTokens.danger, width: 1.5),
    ),
  );
}

/// Sección blanca con icono y título usada por los formularios de gastos.
class ExpenseFormSection extends StatelessWidget {
  const ExpenseFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.accentColor = AppThemeTokens.indigo,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppThemeTokens.borderRadiusLg,
        border: Border.all(color: AppThemeTokens.borderLight),
        boxShadow: AppThemeTokens.subtleCardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: AppThemeTokens.borderRadiusSm,
                  border: Border.all(color: accentColor.withValues(alpha: 0.22)),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Distribuye campos en dos columnas cuando hay ancho suficiente y en una
/// columna cuando el espacio es reducido.
class ExpenseFormColumns extends StatelessWidget {
  const ExpenseFormColumns({
    super.key,
    required this.children,
    this.spacing = 12,
    this.breakpoint = 460,
  });

  final List<Widget> children;
  final double spacing;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint || children.length < 2) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) SizedBox(height: spacing),
                children[index],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) SizedBox(width: spacing),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}

/// Campo de fecha de solo lectura con selector nativo.
class ExpenseDateField extends StatefulWidget {
  const ExpenseDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.isRequired = false,
    this.validator,
    this.enabled = true,
    this.accentColor = AppThemeTokens.indigo,
    this.fieldKey,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isRequired;
  final String? Function(DateTime? value)? validator;
  final bool enabled;
  final Color accentColor;
  final Key? fieldKey;

  @override
  State<ExpenseDateField> createState() => _ExpenseDateFieldState();
}

class _ExpenseDateFieldState extends State<ExpenseDateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _displayValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant ExpenseDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final text = _displayValue(widget.value);
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _displayValue(DateTime? date) {
    if (date == null) return '';
    return DateTimeTool.formatddMMyyEs(date);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = widget.firstDate ?? DateTime(2000);
    final lastDate = widget.lastDate ?? DateTime(now.year + 5);
    var initialDate = widget.value ?? now;

    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (!mounted || picked == null) return;

    _controller.text = _displayValue(picked);
    widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled,
      onTap: widget.enabled ? _pickDate : null,
      keyboardType: TextInputType.none,
      decoration: expenseFormFieldDecoration(
        label: widget.isRequired ? '${widget.label} *' : widget.label,
        accentColor: widget.accentColor,
        prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        suffixIcon: const Icon(Icons.expand_more_rounded, size: 20),
      ),
      validator: (value) {
        if (widget.validator != null) return widget.validator!(widget.value);
        if (widget.isRequired && widget.value == null) {
          return 'Selecciona una fecha';
        }
        return null;
      },
    );
  }
}

/// Campo de monto con prefijo de moneda y parseo robusto.
class ExpenseAmountField extends StatefulWidget {
  const ExpenseAmountField({
    super.key,
    this.initialCents = 0,
    this.onCentsChanged,
    this.accentColor = AppThemeTokens.indigo,
    this.fieldKey,
  });

  final int initialCents;
  final ValueChanged<int>? onCentsChanged;
  final Color accentColor;
  final Key? fieldKey;

  @override
  State<ExpenseAmountField> createState() => _ExpenseAmountFieldState();
}

class _ExpenseAmountFieldState extends State<ExpenseAmountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: formatExpenseAmountInput(widget.initialCents));
  }

  @override
  void didUpdateWidget(covariant ExpenseAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCents != widget.initialCents) {
      final text = formatExpenseAmountInput(widget.initialCents);
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,()\-]')),
      ],
      textInputAction: TextInputAction.next,
      decoration: expenseFormFieldDecoration(
        label: 'Monto *',
        hint: '0.00',
        accentColor: widget.accentColor,
        prefixText: 'C\$ ',
      ),
      validator: (value) {
        final raw = value?.trim() ?? '';
        if (raw.isEmpty) return 'El monto es requerido';

        final cents = parseExpenseAmountCents(raw);
        if (cents == null) return 'Ingresa un monto mayor a cero';

        widget.onCentsChanged?.call(cents);
        return null;
      },
    );
  }
}

/// Interruptor de crédito con explicación del estado resultante.
class ExpenseCreditSwitch extends StatelessWidget {
  const ExpenseCreditSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.accentColor = AppThemeTokens.indigo,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: AppThemeTokens.borderRadiusMd,
        border: Border.all(color: AppThemeTokens.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: AppThemeTokens.borderRadiusSm,
              border: Border.all(color: accentColor.withValues(alpha: 0.20)),
            ),
            child: Icon(
              value ? Icons.schedule_rounded : Icons.check_circle_outline_rounded,
              size: 20,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Es a crédito?',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value
                      ? 'Quedará pendiente de pago hasta que lo marques como pagado.'
                      : 'Se registrará como pagado al guardar el gasto.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: accentColor,
          ),
        ],
      ),
    );
  }
}
