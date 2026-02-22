import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/app_mode/app_mode_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/toast/toast_cubit.dart';
import 'package:kardex_app_front/src/data/adjust_entries_data_source.dart';
import 'package:kardex_app_front/src/data/adjust_exits_data_source.dart';
import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/data/transfers_data_source.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_entries_repository.dart';
import 'package:kardex_app_front/src/domain/repositories/adjust_exits_repository.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';
import 'package:kardex_app_front/src/data/integrations_data_source.dart';
import 'package:kardex_app_front/src/domain/repositories/integrations_repository.dart';

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
    final authDataSource = AuthDataSource();
    final servinDataSource = ServinDataSource();
    final productTransactionDataSource = ProductTransactionsDataSource();
    final expirationLogsDataSource = ExpirationLogsDataSource();
    final devolutionDataSource = DevolutionsDataSource();
    final invoiceDevolutionDataSource = InvoiceDevolutionsDataSource();
    final clientTransDataSource = ClientTransactionsDataSource();
    final servinStatusDataSource = ServinStatusDataSource();
    final adminPanelDataSource = AdminPanelDataSource();
    final dailySummariesDataSource = DailySummariesDataSource();
    final executiveSummariesDataSource = ExecutiveSummariesDataSource();
    final productAccountsDataSource = ProductAccountsDataSource();
    final productStatsDataSource = ProductStatsDataSource();
    final transferDataSource = TransfersDataSource();
    final adjustEntryDatasource = AdjustEntriesDataSource();
    final adjustExitDatasource = AdjustExitsDataSource();
    final integrationsDataSource = IntegrationsDataSource();
    final clientGroupsDataSource = ClientGroupDataSource();

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
          create: (context) => InvoicesRepository(
            invoiceDataSource,
            invoiceDevolutionDataSource,
          ),
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

        RepositoryProvider(
          create: (context) => AuthRepository(
            authDataSource,
            servinStatusDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ServinRepository(
            servinDataSource: servinDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ProductTransactionsRepository(
            productTransactionDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ExpirationLogsRepository(
            expirationLogsDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => DevolutionsRepository(
            devolutionDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ClientTransactionsRepository(
            clientTransDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => AdminPanelRepository(
            adminPanelDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => DailySummariesRepository(
            dailySummariesDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ExecutiveSummariesRepository(
            executiveSummariesDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ProductAccountsRepository(
            productAccountsDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => ProductStatsRepository(
            productStatsDataSource,
          ),
        ),
        RepositoryProvider(
          create: (context) => TransfersRepository(
            transferDataSource,
          ),
        ),
        RepositoryProvider(
          create: (context) => AdjustEntriesRepository(
            adjustEntryDatasource,
          ),
        ),

        RepositoryProvider(
          create: (context) => AdjustExitsRepository(adjustExitDatasource),
        ),
        RepositoryProvider(
          create: (context) => IntegrationsRepository(integrationsDataSource),
        ),
        RepositoryProvider(
          create: (context) => ClientGroupsRepository(clientGroupsDataSource),
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
    final authRepo = context.read<AuthRepository>();
    final branchRepo = context.read<BranchesRepository>();
    final servinRepo = context.read<ServinRepository>();
    final expirationLogRepo = context.read<ExpirationLogsRepository>();
    final clientGroupRepo = context.read<ClientGroupsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppModeCubit()),
        BlocProvider(
          create: (context) => AuthCubit(
            authRepository: authRepo,
            branchesRepository: branchRepo,
            servinRepository: servinRepo,
            clientGroupRepository: clientGroupRepo,
          ),
        ),
        BlocProvider(
          create: (context) => ToastCubit(
            expirationLogsRepository: expirationLogRepo,
          ),
        ),
      ],
      child: child,
    );
  }
}
