import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/config_app/config_app_cubit.dart';
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
    final unitDataSource = UnitsDataSource();
    final productDataSource = ProductsDataSource();
    final entryDocsDataSource = EntryDocsDataSource();
    final exitDocsDataSource = ExitDocsDataSource();
    final entryHistoryDataSource = EntryHistoriesDataSource();
    final exitHistoryDataSource = ExitHistoriesDataSource();
    final inventoryDataSource = InventoriesDataSource();
    final productSaleProfileDataSource = ProductSaleProfilesDataSource();
    final invoiceDataSource = InvoicesDataSource();
    final receiptDataSource = ReceiptsDataSource();
    final orderDataSource = OrdersDataSource();
    final usersDataSource = UsersDataSource();
    final userRolesDataSource = UserRolesDataSource();

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
          create: (context) => ProductsRepository(productDataSource),
        ),

        RepositoryProvider(
          create: (context) => BranchesRepository(branchDataSource),
        ),

        RepositoryProvider(
          create: (context) => UnitsRepository(unitDataSource),
        ),

        RepositoryProvider(
          create: (context) => EntryDocsRepository(entryDocsDataSource),
        ),

        RepositoryProvider(
          create: (context) => ExitDocsRepository(exitDocsDataSource),
        ),

        RepositoryProvider(
          create: (context) => EntryHistoriesRepository(entryHistoryDataSource),
        ),

        RepositoryProvider(
          create: (context) => ExitHistoriesRepository(exitHistoryDataSource),
        ),

        RepositoryProvider(
          create: (context) => InventoriesRepository(inventoryDataSource),
        ),

        RepositoryProvider(
          create: (context) => ProductSaleProfilesRepository(
            productSaleProfileDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => InvoicesRepository(invoiceDataSource),
        ),

        RepositoryProvider(
          create: (context) => ReceiptsRepository(receiptDataSource),
        ),

        RepositoryProvider(
          create: (context) => OrdersRepository(orderDataSource),
        ),

        RepositoryProvider(
          create: (context) => UsersRepository(usersDataSource),
        ),

        RepositoryProvider(
          create: (context) => UserRolesRepository(userRolesDataSource),
        ),
      ],
      child: GlobalCubitProvider(
        child: child,
      ),
    );
  }
}

class GlobalCubitProvider extends StatelessWidget {
  const GlobalCubitProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConfigAppCubit()),
      ],
      child: child,
    );
  }
}
