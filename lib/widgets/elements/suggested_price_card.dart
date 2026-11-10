import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

/// Tarjeta de precio sugerido calculado a partir del costo y el margen.
///
/// Si hay una unidad extra con factor de conversión mayor a 1, muestra el
/// precio sugerido equivalente por esa unidad y el costo equivalente.
class SuggestedPriceCard extends StatelessWidget {
  const SuggestedPriceCard({
    super.key,
    required this.costInCents,
    required this.profitMargin,
    required this.baseUnitName,
    required this.onApplySuggested,
    this.selectedUnitName,
    this.selectedUnitFactor = 1,
  });

  final int costInCents;
  final double profitMargin;
  final String baseUnitName;
  final ValueChanged<int> onApplySuggested;

  final String? selectedUnitName;
  final int selectedUnitFactor;

  @override
  Widget build(BuildContext context) {
    if (costInCents <= 0) {
      return const SizedBox.shrink();
    }

    final suggestedPriceInCents = (costInCents * (1 + profitMargin / 100)).round();
    final factor = selectedUnitFactor <= 0 ? 1 : selectedUnitFactor;
    final hasExtra = selectedUnitName != null && factor > 1;
    final extraSuggestedCents = suggestedPriceInCents * factor;
    final extraCostInCents = costInCents * factor;
    final marginText = profitMargin.toStringAsFixed(
      profitMargin.truncateToDouble() == profitMargin ? 0 : 1,
    );

    final mainText = hasExtra
        ? "Precio Sugerido (+$marginText%): ${NumberFormatter.convertToMoneyLike(extraSuggestedCents)} por $selectedUnitName"
        : "Precio Sugerido (+$marginText%): ${NumberFormatter.convertToMoneyLike(suggestedPriceInCents)}";

    final subtitleText = hasExtra
        ? "Costo base: ${NumberFormatter.convertToMoneyLike(costInCents)} ($baseUnitName) · Equivale a ${NumberFormatter.convertToMoneyLike(extraCostInCents)} por $selectedUnitName"
        : "Costo base: ${NumberFormatter.convertToMoneyLike(costInCents)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPressed: () => onApplySuggested(suggestedPriceInCents),
            child: const Text("Usar Precio Sugerido", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
