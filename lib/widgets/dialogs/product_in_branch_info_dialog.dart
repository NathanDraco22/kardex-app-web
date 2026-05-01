import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/title_label.dart';

Future<void> showProductInBranchInfoDialog(
  BuildContext context, {
  required ProductInDbInBranch product,
}) async {
  return await showDialog<void>(
    context: context,
    builder: (context) => ProductInBranchInfoDialog(product: product),
  );
}

class ProductInBranchInfoDialog extends StatelessWidget {
  const ProductInBranchInfoDialog({
    super.key,
    required this.product,
  });

  final ProductInDbInBranch product;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                product.displayCode,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TitleLabel(
                      title: "Marca",
                      bigTitle: product.brandName,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: TitleLabel(
                      title: "Unidad",
                      bigTitle: product.unitName,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Precios
              const Text(
                "Precios de Venta",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TitleLabel(
                      title: "Precio 1",
                      bigTitle: NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: TitleLabel(
                      title: "Precio 2",
                      bigTitle: NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice2),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: TitleLabel(
                      title: "Precio 3",
                      bigTitle: NumberFormatter.convertToMoneyLike(product.saleProfile.salePrice3),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Costos
              const Text(
                "Costos e Inventario",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TitleLabel(
                      title: "Promedio",
                      bigTitle: NumberFormatter.convertFromCentsToUnitsCurrency(product.account.averageCost),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: TitleLabel(
                      title: "Último",
                      bigTitle: NumberFormatter.convertFromCentsToUnitsCurrency(product.account.lastCost),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                  Expanded(
                    child: TitleLabel(
                      title: "Mayor",
                      bigTitle: NumberFormatter.convertFromCentsToUnitsCurrency(product.account.maximumCost),
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TitleLabel(
                title: "Existencia Disponible",
                bigTitle: product.account.availableStock.toString(),
                crossAxisAlignment: CrossAxisAlignment.center,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
