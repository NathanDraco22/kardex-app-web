import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';

/// Dropdown interactivo para seleccionar el nivel de precio activo en la Terminal de Venta.
class TerminalPriceLevelDropdown extends StatelessWidget {
  const TerminalPriceLevelDropdown({
    super.key,
    required this.viewController,
    this.height = 38,
    this.fontSize = 13,
    this.iconSize = 16,
  });

  final SaleTerminalViewController viewController;
  final double height;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.sell_outlined, size: iconSize, color: Colors.blueGrey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: viewController.selectedPriceLevel,
                    isDense: true,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text("Precio: Nivel 1", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Precio: Nivel 2", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text("Precio: Nivel 3", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text("Precio: Nivel 4", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        viewController.selectedPriceLevel = val;
                        viewController.requestSearchFocus();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
