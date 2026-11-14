import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_mode/app_mode_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/cubits/near_expiration/near_expiration_cubit.dart';
import 'package:kardex_app_front/cubits/shortcuts/shortcuts_cubit.dart';
import 'package:kardex_app_front/cubits/toast/toast_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/shift/shift_cubit.dart';

import 'package:kardex_app_front/src/core/app_config_manager.dart';
import 'package:kardex_app_front/src/core/app_kardex_config.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_business/kardex_business.dart';

class ProviderContainer extends StatelessWidget {
  const ProviderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    KardexClient.initialize(AppKardexConfig());

    final clientDataSource = ClientsDataSource();
    final supplierDataSource = SuppliersDataSource();
    final productPriceDataSource = ProductPricesDataSource();
    final branchDataSource = BranchesDataSource();
    final productCateDataSource = ProductCategoriesDataSource();
    final unitDataSource = UnitsDataSource();
    final productDataSource = ProductsDataSource();
    final inventoryDataSource = InventoriesDataSource();
    final productSaleProfileDataSource = ProductSaleProfilesDataSource();
    final invoiceDataSource = InvoicesDataSource();
    final receiptDataSource = ReceiptsDataSource();
    final orderDataSource = OrdersDataSource();
    final usersDataSource = UsersDataSource();
    final userRolesDataSource = UserRolesDataSource();
    final authDataSource = AuthDataSource(sessionStore: SessionManager());
    final servinDataSource = ServinDataSource();
    final productTransactionDataSource = ProductTransactionsDataSource();
    final expirationLogsDataSource = ExpirationLogsDataSource();
    final devolutionDataSource = DevolutionsDataSource();
    final creditNotesDataSource = CreditNotesDataSource();
    final compositeDataSource = CompositeDataSource();
    final invoiceDevolutionDataSource = InvoiceDevolutionsDataSource();
    final clientTransDataSource = ClientTransactionsDataSource();
    final servinStatusDataSource = ServinStatusDataSource();
    final adminPanelDataSource = AdminPanelDataSource();
    final dailySummariesDataSource = DailySummariesDataSource();
    final executiveSummariesDataSource = ExecutiveSummariesDataSource();
    final productAccountsDataSource = ProductAccountsDataSource();
    final productStatsDataSource = ProductStatsDataSource();
    final transferDataSource = TransfersDataSource();
    final entryDocsDataSource = EntryDocsDataSource();
    final entryHistoryDataSource = EntryHistoriesDataSource();
    final exitDocsDatasource = ExitDocsDataSource();
    final exitHistoryDatasource = ExitHistoriesDataSource();
    final adjustEntryDatasource = AdjustEntriesDataSource();
    final adjustExitDatasource = AdjustExitsDataSource();
    final adjustmentRequestsDataSource = AdjustmentRequestsDataSource();
    final integrationsDataSource = IntegrationsDataSource();
    final clientGroupsDataSource = ClientGroupDataSource();
    final reportsDataSource = ReportsDataSource();
    final expensesDataSource = ExpensesDataSource();
    final expenseCategoriesDataSource = ExpenseCategoriesDataSource();
    final holdSalesDataSource = HoldSalesDataSource();
    final appSettingsDataSource = AppSettingsDataSource();
    final unitScaleDataSource = UnitScalesDataSource();
    final importsDataSource = ImportsDataSource();
    final shiftsDataSource = ShiftsDataSource();
    final shiftCashMovementsDataSource = ShiftCashMovementsDataSource();

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
          create: (context) => EntryDocsRepository(entryDocsDataSource),
        ),

        RepositoryProvider(
          create: (context) => EntryHistoriesRepository(entryHistoryDataSource),
        ),

        RepositoryProvider(
          create: (context) => ExitDocsRepository(exitDocsDatasource),
        ),

        RepositoryProvider(
          create: (context) => ExitHistoriesRepository(exitHistoryDatasource),
        ),

        RepositoryProvider(
          create: (context) => BranchesRepository(branchDataSource),
        ),

        RepositoryProvider(
          create: (context) => UnitsRepository(unitDataSource),
        ),

        RepositoryProvider(
          create: (context) => UnitScalesRepository(unitScaleDataSource),
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
            appConfigStore: AppConfigManager(),
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
          create: (context) => CompositeRepository(
            compositeDataSource,
          ),
        ),

        RepositoryProvider(
          create: (context) => CreditNotesRepository(
            creditNotesDataSource,
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
          create: (context) => AdjustmentRequestsRepository(
            adjustmentRequestsDataSource,
          ),
          dispose: (repo) => repo.disposeReactiveRepo(),
        ),
        RepositoryProvider(
          create: (context) => IntegrationsRepository(integrationsDataSource),
        ),
        RepositoryProvider(
          create: (context) => ClientGroupsRepository(clientGroupsDataSource),
        ),
        RepositoryProvider(
          create: (context) => ReportsRepository(reportsDataSource),
        ),
        RepositoryProvider(
          create: (context) => ExpensesRepository(expensesDataSource),
        ),
        RepositoryProvider(
          create: (context) => ExpenseCategoriesRepository(expenseCategoriesDataSource),
        ),
        RepositoryProvider(
          create: (context) => HoldSalesRepository(holdSalesDataSource),
        ),
        RepositoryProvider(
          create: (context) => AppSettingsRepository(appSettingsDataSource),
        ),
        RepositoryProvider(
          create: (context) => ImportsRepository(importsDataSource),
        ),
        RepositoryProvider(
          create: (context) => ShiftsRepository(shiftsDataSource),
          dispose: (repo) => repo.disposeReactiveRepo(),
        ),
        RepositoryProvider(
          create: (context) => ShiftCashMovementsRepository(shiftCashMovementsDataSource),
          dispose: (repo) => repo.disposeReactiveRepo(),
        ),
      ],
      child: GlobalCubitProvider(
        child: child,
      ),
    );
  }
}

class GlobalCubitProvider extends StatefulWidget {
  const GlobalCubitProvider({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalCubitProvider> createState() => _GlobalCubitProviderState();
}

class _GlobalCubitProviderState extends State<GlobalCubitProvider> {
  late final AuthCubit _authCubit;
  late final AppSettingsCubit _appSettingsCubit;
  late final ShiftCubit _shiftCubit;

  @override
  void initState() {
    super.initState();
    final authRepo = context.read<AuthRepository>();
    final branchRepo = context.read<BranchesRepository>();
    final servinRepo = context.read<ServinRepository>();
    final clientGroupRepo = context.read<ClientGroupsRepository>();
    final appSettingsRepo = context.read<AppSettingsRepository>();
    final shiftsRepo = context.read<ShiftsRepository>();

    _authCubit = AuthCubit(
      authRepository: authRepo,
      branchesRepository: branchRepo,
      servinRepository: servinRepo,
      clientGroupRepository: clientGroupRepo,
    );
    getIt.registerSingleton<AuthCubit>(_authCubit);

    _appSettingsCubit = AppSettingsCubit(appSettingsRepo);
    getIt.registerSingleton<AppSettingsCubit>(_appSettingsCubit);

    _shiftCubit = ShiftCubit(shiftsRepository: shiftsRepo);
    getIt.registerSingleton<ShiftCubit>(_shiftCubit);
  }

  @override
  void dispose() {
    getIt.unregister<ShiftCubit>();
    _shiftCubit.close();
    getIt.unregister<AuthCubit>();
    _authCubit.close();
    getIt.unregister<AppSettingsCubit>();
    _appSettingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expirationLogRepo = context.read<ExpirationLogsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppModeCubit()),
        BlocProvider(create: (context) => ShortcutsCubit()),
        BlocProvider(
          create: (context) => ToastCubit(
            expirationLogsRepository: expirationLogRepo,
          ),
        ),
        BlocProvider(
          create: (context) => NearExpirationCubit(
            expirationLogsRepository: expirationLogRepo,
          ),
        ),
        BlocProvider.value(value: _appSettingsCubit),
        BlocProvider.value(value: _shiftCubit),
      ],
      child: widget.child,
    );
  }
}
