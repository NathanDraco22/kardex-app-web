import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/read_product_in_branch/read_product_in_branch_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/product_price_catalog/web/product_catalog_web.dart';

class ProductPriceCatalogScreen extends StatelessWidget {
  const ProductPriceCatalogScreen({super.key});

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
        title: const Text("Catálogo de Precios"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ProductCatalogWeb();
  }
}
