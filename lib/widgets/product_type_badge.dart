import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';

/// Badge compacto que identifica el tipo de producto cuando no es un artículo inventariable.
class ProductTypeBadge extends StatelessWidget {
  const ProductTypeBadge({
    super.key,
    required this.productType,
    this.compact = false,
    this.showItemBadge = false,
  });

  final ProductType productType;
  final bool compact;
  final bool showItemBadge;

  @override
  Widget build(BuildContext context) {
    if (productType == ProductType.item && !showItemBadge) {
      return const SizedBox.shrink();
    }

    final (Color bgColor, Color borderColor, Color textColor, IconData icon, String label) =
        switch (productType) {
      ProductType.service => (
        Colors.deepPurple.shade50,
        Colors.deepPurple.shade200,
        Colors.deepPurple.shade700,
        Icons.miscellaneous_services_rounded,
        compact ? 'Servicio' : 'Servicio',
      ),
      ProductType.nonInventory => (
        Colors.teal.shade50,
        Colors.teal.shade200,
        Colors.teal.shade800,
        Icons.sell_outlined,
        compact ? 'Sin inv.' : 'No inventariable',
      ),
      ProductType.item => (
        Colors.blue.shade50,
        Colors.blue.shade200,
        Colors.blue.shade800,
        Icons.inventory_2_outlined,
        'Artículo',
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 1.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: textColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector segmentado reutilizable para elegir `ProductType` en formularios de creación/edición.
class ProductTypeSelector extends StatelessWidget {
  const ProductTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final ProductType selectedType;
  final ValueChanged<ProductType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Tipo de Producto*",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        SegmentedButton<ProductType>(
          segments: const [
            ButtonSegment<ProductType>(
              value: ProductType.item,
              label: Text("Artículo", style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.inventory_2_outlined, size: 16),
            ),
            ButtonSegment<ProductType>(
              value: ProductType.nonInventory,
              label: Text("No inv.", style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.sell_outlined, size: 16),
            ),
            ButtonSegment<ProductType>(
              value: ProductType.service,
              label: Text("Servicio", style: TextStyle(fontSize: 12)),
              icon: Icon(Icons.miscellaneous_services_rounded, size: 16),
            ),
          ],
          selected: {selectedType},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
        ),
      ],
    );
  }
}
