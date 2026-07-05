import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
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
    final isSeller = RoleTools.isSeller().$1;

    Widget buildPriceCopyable(String title, int priceInCents) {
      final priceString = NumberFormatter.convertToMoneyLike(priceInCents);
      return Expanded(
        child: Tooltip(
          message: priceInCents == 0 ? "No se puede copiar" : "Tocar para copiar",
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 1,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: priceInCents == 0
                  ? null
                  : () {
                      final text =
                          "${product.name} \n${product.brandName} - ${product.unitName} \nPrecio: $priceString";
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Copiado: ${product.name} - $priceString"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TitleLabel(
                  title: title,
                  bigTitle: priceString,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                spacing: 8,
                children: [
                  buildPriceCopyable("Precio 1", product.saleProfile.salePrice),
                  buildPriceCopyable("Precio 2", product.saleProfile.salePrice2),
                  buildPriceCopyable("Precio 3", product.saleProfile.salePrice3),
                  buildPriceCopyable("Precio 4", product.saleProfile.salePrice4),
                ],
              ),

              if (!isSeller) ...[
                const Divider(height: 24),
                // Costos
                const Text(
                  "Costos",
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
              ],

              const Divider(height: 24),
              const Text(
                "Inventario",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
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
