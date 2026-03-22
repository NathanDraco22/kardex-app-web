import 'package:flutter/material.dart';

class InventoryRow extends StatelessWidget {
  final String productName;
  final String code;
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
    required this.code,
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
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.grey.withValues(alpha: 0.1),
      child: Ink(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.qr_code, size: 16),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      brandName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      unitName,
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
                  Expanded(child: Text("Existen", style: TextStyle(fontSize: 16))),
                  Expanded(
                    flex: 2,
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
                      stock,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      unitCost,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      totalValue,
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
