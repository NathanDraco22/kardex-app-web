import 'package:flutter/material.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/supplier_selection_dialog.dart';

class SupplierSelector extends StatefulWidget {
  const SupplierSelector({super.key, this.onSupplierSelected});

  final Function(SupplierInDb?)? onSupplierSelected;

  @override
  State<SupplierSelector> createState() => _SupplierSelectorState();
}

class _SupplierSelectorState extends State<SupplierSelector> {
  SupplierInDb? selectedSupplier;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              final selected = await showSupplierSelectionDialog(context);
              if (selected != null) {
                setState(() {
                  selectedSupplier = selected;
                });
                widget.onSupplierSelected?.call(selected);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  selectedSupplier != null ? selectedSupplier!.name : "Filtrar por Proveedor",
                  style: TextStyle(
                    fontWeight: selectedSupplier != null ? FontWeight.bold : FontWeight.normal,
                    color: selectedSupplier != null ? Theme.of(context).primaryColor : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          if (selectedSupplier != null) ...[
            const VerticalDivider(width: 1),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: () {
                setState(() {
                  selectedSupplier = null;
                });
                widget.onSupplierSelected?.call(null);
              },
            ),
          ],
        ],
      ),
    );
  }
}
