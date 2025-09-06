part of '../product_price_setting_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadProductSaleProfileCubit>().state;

    if (state is ReadProductSaleProfileLoading) {
      return const Column(
        children: [
          LinearProgressIndicator(),
        ],
      );
    }

    if (state is ReadProductSaleProfileError) {
      return Center(child: Text(state.message));
    }

    state as ReadProductSaleProfileSuccess;

    final profiles = state.profiles;

    return BasicTableListView(
      columns: [
        BasicTableColumn(
          flex: 4,
          label: const Text(
            "Producto",
          ),
        ),
        BasicTableColumn(
          flex: 2,
          label: const Text(
            "Ultima Compra",
            textAlign: TextAlign.center,
          ),
        ),
        BasicTableColumn(
          flex: 2,
          label: const Text(
            "Costo",
            textAlign: TextAlign.center,
          ),
        ),
        BasicTableColumn(
          flex: 1,
          label: const Text(
            "Precio",
            textAlign: TextAlign.center,
          ),
        ),
        BasicTableColumn(
          flex: 1,
          label: const SizedBox(),
        ),
      ],
      itemCount: profiles.length,
      rowBuilder: (context, index) {
        Color color = index.isOdd ? Colors.white : Colors.grey.shade200;

        if (state is HighlightedProductSaleProfile) {
          if (state.updatedProfiles.any((element) => element.productId == profiles[index].productId)) {
            color = Colors.blue.shade100;
          }
        }

        final profile = profiles[index];
        final averageCost = NumberFormatter.convertToMoneyLike(
          profile.account.averageCost,
        );

        final price = NumberFormatter.convertToMoneyLike(
          profile.salePrice,
        );

        final lastCost = NumberFormatter.convertToMoneyLike(
          profile.account.lastCost,
        );
        return BasicTableRow(
          color: color,
          cells: [
            BasicTableCell(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    profile.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          profile.product.brandName,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          profile.product.unitName,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            BasicTableCell(
              content: Text(
                lastCost,
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                averageCost,
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: Text(
                price,
                textAlign: TextAlign.center,
              ),
            ),
            BasicTableCell(
              content: IconButton(
                onPressed: () {
                  showProductPriceDetail(context, profile);
                },
                icon: const Icon(
                  Icons.edit,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
