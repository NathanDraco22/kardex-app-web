import 'package:flutter/material.dart';

class InventoryRow extends StatelessWidget {
  final String productName;
  final String brandName;
  final String unitName;
  final String stock;
  final String unitCost;
  final String totalValue;
  final Color? color;
  final VoidCallback? onTap;

  const InventoryRow({
    super.key,
    required this.productName,
    required this.brandName,
    required this.unitName,
    required this.stock,
    required this.unitCost,
    required this.totalValue,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Usa InkWell para los efectos visuales y el onTap
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.grey.withValues(alpha: 0.1),
      child: Ink(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          // He usado Column en lugar de un Row con Column adentro para simplificar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                productName, // <-- Usa la propiedad
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      brandName, // <-- Usa la propiedad
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      unitName, // <-- Usa la propiedad
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Expanded(child: Text("Existencia", style: TextStyle(fontSize: 16))),
                  Expanded(
                    child: Text("Costo Unit", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("Total", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stock, // <-- Usa la propiedad
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      unitCost, // <-- Usa la propiedad
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      totalValue, // <-- Usa la propiedad
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
