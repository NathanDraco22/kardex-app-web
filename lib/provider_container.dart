import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

class ProviderContainer extends StatelessWidget {
  const ProviderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clientDataSource = ClientsDataSource();
    final supplierDataSource = SuppliersDataSource();
    final productPriceDataSource = ProductPricesDataSource();
    final branchDataSource = BranchesDataSource();
    final productCateDataSource = ProductCategoriesDataSource();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => ClientsRepository(clientDataSource),
        ),

        RepositoryProvider(
          create: (context) => SuppliersRepository(supplierDataSource),
        ),

        RepositoryProvider(
          create: (context) => ProductCategoriesRepository(productCateDataSource),
        ),

        RepositoryProvider(
          create: (context) => ProductPricesRepository(
            productPriceDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => BranchesRepository(branchDataSource),
        ),
      ],
      child: child,
    );
  }
}
