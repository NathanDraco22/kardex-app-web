import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/design_system/app_theme_tokens.dart';

/// Bancos locales disponibles para selección rápida en pagos por transferencia o tarjeta.
const List<String> kSupportedBanks = [
  'BAC',
  'LAFISE',
  'BANPRO',
  'FICOHSA',
  'BDF',
];

/// Combina el [bank] opcional con el número de [reference] para guardarlo en `bankReference`.
String formatBankReference({
  String? bank,
  required String reference,
}) {
  final cleanRef = reference.trim();
  final cleanBank = bank?.trim() ?? '';
  if (cleanBank.isEmpty) return cleanRef;
  if (cleanRef.isEmpty) return cleanBank;
  return '$cleanBank - $cleanRef';
}

/// Selector compacto de chips de banco para pagos con transferencia o tarjeta.
class BankChipsSelector extends StatelessWidget {
  final String? selectedBank;
  final ValueChanged<String?> onChanged;
  final List<String> banks;

  const BankChipsSelector({
    super.key,
    required this.selectedBank,
    required this.onChanged,
    this.banks = kSupportedBanks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banco (opcional)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppThemeTokens.neutral,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: banks.map((bank) {
            final isSelected = selectedBank == bank;
            return ChoiceChip(
              label: Text(
                bank,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              selected: isSelected,
              selectedColor: AppThemeTokens.indigo,
              backgroundColor: AppThemeTokens.surfaceLight,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppThemeTokens.indigo
                    : AppThemeTokens.borderLight,
              ),
              visualDensity: VisualDensity.compact,
              onSelected: (selected) {
                onChanged(selected ? bank : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
