import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/product_accounts/read_product_accounts_cubit.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

class ProductStockDialog extends StatelessWidget {
  const ProductStockDialog({super.key, required this.product});

  final ProductInDb product;

  static Future<void> show(BuildContext context, ProductInDb product) {
    return showDialog(
      context: context,
      builder: (context) => ProductStockDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProductAccountsRepository>();
    return BlocProvider(
      create: (context) => ReadProductAccountsCubit(
        productAccountsRepository: repository,
      )..getProductAccounts(product.id),
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  "${product.unitName} - ${product.brandName}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Stock por Sucursal",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const Divider(),
                const Expanded(
                  child: _StockList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StockList extends StatelessWidget {
  const _StockList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadProductAccountsCubit, ReadProductAccountsState>(
      builder: (context, state) {
        if (state is ReadProductAccountsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReadProductAccountsFailure) {
          return Center(child: Text("Error: ${state.message}"));
        }

        if (state is ReadProductAccountsSuccess) {
          if (state.accounts.isEmpty) {
            return const Center(child: Text("No se encontraron registros de este producto."));
          }

          return ListView.separated(
            itemCount: state.accounts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final account = state.accounts[index];
              final branch = BranchesTool.getBranchById(account.branchId);

              return ListTile(
                title: Text(
                  branch.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Stock: ${account.currentStock}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (account.promiseStock > 0)
                      Text(
                        "Comprometido: ${account.promiseStock}",
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
