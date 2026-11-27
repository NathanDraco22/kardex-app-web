import 'package:material_ui/material_ui.dart';
import 'package:kardex_business/kardex_business.dart';

/// Tarjeta de precio sugerido calculado a partir del costo y el margen.
///
/// Si hay una unidad extra con factor de conversión mayor a 1, muestra el
/// precio sugerido equivalente por esa unidad y el costo equivalente.
class SuggestedPriceCard extends StatelessWidget {
  const SuggestedPriceCard({
    super.key,
    required this.suggestion,
    required this.baseUnitName,
    required this.onApplySuggested,
    this.selectedUnitName,
  });

  final SuggestedPrice suggestion;
  final String baseUnitName;
  final ValueChanged<int> onApplySuggested;

  final String? selectedUnitName;

  @override
  Widget build(BuildContext context) {
    if (suggestion.costInCents <= 0) {
      return const SizedBox.shrink();
    }

    final factor = suggestion.unitFactor;
    final hasExtra = selectedUnitName != null && factor > 1;
    final marginText = suggestion.marginPercent.toStringAsFixed(
      suggestion.marginPercent.truncateToDouble() == suggestion.marginPercent ? 0 : 1,
    );

    final mainText = hasExtra
        ? "Precio Sugerido (+$marginText%): ${NumberFormatter.convertToMoneyLike(suggestion.totalPriceInCents)} por $selectedUnitName"
        : "Precio Sugerido (+$marginText%): ${NumberFormatter.convertToMoneyLike(suggestion.priceInCents)}";

    final subtitleText = hasExtra
        ? "Costo base: ${NumberFormatter.convertToMoneyLike(suggestion.costInCents)} ($baseUnitName) · Equivale a ${NumberFormatter.convertToMoneyLike(suggestion.totalCostInCents)} por $selectedUnitName"
        : "Costo base: ${NumberFormatter.convertToMoneyLike(suggestion.costInCents)}";

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
            onPressed: () => onApplySuggested(suggestion.priceInCents),
            child: const Text("Usar Precio Sugerido", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
