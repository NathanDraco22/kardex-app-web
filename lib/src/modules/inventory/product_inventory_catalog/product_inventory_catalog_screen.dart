import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/read_product_in_branch/read_product_in_branch_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/product_inventory_catalog/web/product_inventory_catalog_web.dart';

class ProductInventoryCatalogScreen extends StatelessWidget {
  const ProductInventoryCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsRepo = context.read<ProductsRepository>();
    return BlocProvider(
      create: (context) {
        return ReadProductInBranchCubit(
          productsRepository: productsRepo,
        )..getProducts();
      },
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo de Inventario"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ProductInventoryCatalogWeb();
  }
}
