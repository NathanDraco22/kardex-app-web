import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/home/data/home_shortcut_resolver.dart';
import 'package:kardex_app_front/widgets/gates/gates.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAppSettingsDataSource implements AppSettingsDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository() : super(_FakeAppSettingsDataSource());
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBranchesRepository implements BranchesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeServinRepository implements ServinRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthCubit _createTestAuthCubit() {
  return AuthCubit(
    authRepository: _FakeAuthRepository(),
    branchesRepository: _FakeBranchesRepository(),
    servinRepository: _FakeServinRepository(),
  );
}

AppSettingsCubit _createTestAppSettingsCubit() {
  return AppSettingsCubit(_FakeAppSettingsRepository());
}

Authenticated _buildAuthenticated({
  String userId = 'user-1',
  List<String> access = const [],
  bool isUsingExpirationDate = true,
}) {
  final branch = BranchInDb(
    id: 'branch-1',
    name: 'Sucursal Central',
    idCard: 'J0310000000000',
    address: 'Managua',
    email: 'test@example.com',
    phone: '88888888',
    createdAt: DateTime(2026),
  );

  return Authenticated(
    LoginResponse(
      accessToken: 'token',
      user: UserInDbWithRole(
        id: userId,
        username: userId,
        password: '',
        role: 'Tester',
        branches: const ['branch-1'],
        createdAt: DateTime(2026),
        userRole: UserRole(name: 'Tester', access: access),
      ),
    ),
    branch,
    [branch],
    Servin(
      name: 'Test Servin',
      nickname: 'test',
      url: 'https://example.com',
      isActive: true,
      isUsingExpirationDate: isUsingExpirationDate,
    ),
  );
}

AppSettingModel _buildAppSettings({
  bool useOrders = true,
  bool useQuotations = true,
  bool useShifts = false,
  bool useExpirationDates = true,
}) {
  return AppSettingModel.fromJson({
    'id': 'Default',
    'createdAt': 1000,
    'useOrders': useOrders,
    'useQuotations': useQuotations,
    'useShifts': useShifts,
    'useExpirationDates': useExpirationDates,
  });
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  group('Gate y combinadores base', () {
    testWidgets('evalúa múltiples filtros en modo all (AND) y any (OR)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          Column(
            children: [
              Gate(
                filters: [
                  PredicateGateFilter((_) => true),
                  PredicateGateFilter((_) => false),
                ],
                fallback: const Text('Bloqueado AND'),
                child: const Text('Permitido AND'),
              ),
              Gate(
                matchMode: GateMatchMode.any,
                filters: [
                  PredicateGateFilter((_) => false),
                  PredicateGateFilter((_) => true),
                ],
                fallback: const Text('Bloqueado OR'),
                child: const Text('Permitido OR'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Bloqueado AND'), findsOneWidget);
      expect(find.text('Permitido AND'), findsNothing);
      expect(find.text('Permitido OR'), findsOneWidget);
      expect(find.text('Bloqueado OR'), findsNothing);
    });

    testWidgets('soporta AnyGateFilter, NotGateFilter y fallback por filtro', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithApp(
          Column(
            children: [
              Gate(
                filters: [
                  AnyGateFilter([
                    PredicateGateFilter((_) => false),
                    PredicateGateFilter((_) => true),
                  ]),
                  NotGateFilter(PredicateGateFilter((_) => false)),
                ],
                child: const Text('Combinado OK'),
              ),
              Gate(
                filters: [
                  PredicateGateFilter(
                    (_) => false,
                    fallback: const Text('Fallback del primer filtro'),
                  ),
                  PredicateGateFilter(
                    (_) => false,
                    fallback: const Text('Fallback del segundo filtro'),
                  ),
                ],
                fallback: const Text('Fallback general'),
                child: const Text('No visible'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Combinado OK'), findsOneWidget);
      expect(find.text('Fallback del primer filtro'), findsOneWidget);
      expect(find.text('Fallback del segundo filtro'), findsNothing);
      expect(find.text('Fallback general'), findsNothing);
    });

    testWidgets('aplica width y height cuando se especifican', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          Gate(
            width: 120,
            height: 44,
            filters: [PredicateGateFilter((_) => false)],
            child: const Text('Oculto'),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 120);
      expect(sizedBox.height, 44);
    });
  });

  group('Filtros de dominio y reactividad', () {
    testWidgets(
      'OrdersGateFilter, QuotationsGateFilter y ShiftsGateFilter reaccionan a AppSettingsCubit',
      (tester) async {
        final settingsCubit = _createTestAppSettingsCubit();
        addTearDown(settingsCubit.close);
        getIt.registerSingleton<AppSettingsCubit>(settingsCubit);

        settingsCubit.emit(
          AppSettingsLoaded(
            _buildAppSettings(
              useOrders: false,
              useQuotations: true,
              useShifts: false,
            ),
          ),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            const Column(
              children: [
                Gate(
                  filters: [OrdersGateFilter()],
                  child: Text('Órdenes'),
                ),
                Gate(
                  filters: [QuotationsGateFilter()],
                  child: Text('Cotizaciones'),
                ),
                Gate(
                  filters: [
                    AnyGateFilter([
                      QuotationsGateFilter(),
                      OrdersGateFilter(),
                    ]),
                  ],
                  child: Text('Cotizaciones u Órdenes'),
                ),
                Gate(
                  filters: [ShiftsGateFilter()],
                  child: Text('Turnos'),
                ),
              ],
            ),
          ),
        );

        expect(find.text('Órdenes'), findsNothing);
        expect(find.text('Cotizaciones'), findsOneWidget);
        expect(find.text('Cotizaciones u Órdenes'), findsOneWidget);
        expect(find.text('Turnos'), findsNothing);

        settingsCubit.emit(
          AppSettingsLoaded(
            _buildAppSettings(
              useOrders: true,
              useQuotations: false,
              useShifts: true,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Órdenes'), findsOneWidget);
        expect(find.text('Cotizaciones'), findsNothing);
        expect(find.text('Cotizaciones u Órdenes'), findsOneWidget);
        expect(find.text('Turnos'), findsOneWidget);
      },
    );

    testWidgets(
      'ExpirationDateGateFilter valida servin.isUsingExpirationDate y AppSettings',
      (tester) async {
        final authCubit = _createTestAuthCubit();
        final settingsCubit = _createTestAppSettingsCubit();
        addTearDown(authCubit.close);
        addTearDown(settingsCubit.close);
        getIt.registerSingleton<AuthCubit>(authCubit);
        getIt.registerSingleton<AppSettingsCubit>(settingsCubit);

        authCubit.emit(_buildAuthenticated(isUsingExpirationDate: false));
        settingsCubit.emit(
          AppSettingsLoaded(_buildAppSettings(useExpirationDates: true)),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            const Gate(
              filters: [ExpirationDateGateFilter()],
              child: Text('Caducidad'),
            ),
          ),
        );

        expect(find.text('Caducidad'), findsNothing);

        authCubit.emit(_buildAuthenticated(isUsingExpirationDate: true));
        await tester.pumpAndSettle();
        expect(find.text('Caducidad'), findsOneWidget);

        settingsCubit.emit(
          AppSettingsLoaded(_buildAppSettings(useExpirationDates: false)),
        );
        await tester.pumpAndSettle();
        expect(find.text('Caducidad'), findsNothing);
      },
    );

    testWidgets(
      'RolePermissionGateFilter y RootUserGateFilter evalúan permisos y root',
      (tester) async {
        final authCubit = _createTestAuthCubit();
        addTearDown(authCubit.close);
        getIt.registerSingleton<AuthCubit>(authCubit);

        authCubit.emit(
          _buildAuthenticated(
            userId: 'cashier-1',
            access: [CommercialSubModules.createInvoice.name],
          ),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            const Column(
              children: [
                Gate(
                  filters: [
                    RolePermissionGateFilter(
                      permissions: [CommercialSubModules.createInvoice],
                    ),
                  ],
                  child: Text('Facturar'),
                ),
                Gate(
                  filters: [
                    RolePermissionGateFilter(
                      permissions: [CommercialSubModules.orders],
                      mode: PermissionMode.blacklist,
                    ),
                  ],
                  child: Text('Sin permiso orders'),
                ),
                Gate(
                  filters: [
                    RootUserGateFilter(fallback: Text('Solo root')),
                    RolePermissionGateFilter(
                      permissions: [Modules.settings],
                      fallback: Text('Sin permiso settings'),
                    ),
                  ],
                  child: Text('Importaciones'),
                ),
              ],
            ),
          ),
        );

        expect(find.text('Facturar'), findsOneWidget);
        expect(find.text('Sin permiso orders'), findsOneWidget);
        expect(find.text('Solo root'), findsOneWidget);
        expect(find.text('Importaciones'), findsNothing);

        authCubit.emit(_buildAuthenticated(userId: 'root'));
        await tester.pump();

        expect(find.text('Importaciones'), findsOneWidget);
        expect(find.text('Solo root'), findsNothing);
      },
    );

    testWidgets(
      'HomeShortcutResolver evalúa HomeSubmoduleItem.gates correctamente',
      (tester) async {
        final authCubit = _createTestAuthCubit();
        final settingsCubit = _createTestAppSettingsCubit();
        addTearDown(authCubit.close);
        addTearDown(settingsCubit.close);
        getIt.registerSingleton<AuthCubit>(authCubit);
        getIt.registerSingleton<AppSettingsCubit>(settingsCubit);

        authCubit.emit(
          _buildAuthenticated(
            userId: 'seller-1',
            access: [
              Modules.commercial.name,
              Modules.settings.name,
              CommercialSubModules.orders.name,
            ],
            isUsingExpirationDate: false,
          ),
        );
        settingsCubit.emit(
          AppSettingsLoaded(
            _buildAppSettings(
              useOrders: true,
              useQuotations: false,
              useShifts: false,
              useExpirationDates: true,
            ),
          ),
        );

        late HomeShortcutResolver resolver;
        await tester.pumpWidget(
          _wrapWithApp(
            Builder(
              builder: (context) {
                resolver = HomeShortcutResolver.build(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(resolver.canAccess('current-orders'), isTrue);
        expect(resolver.canAccess('quotation-order-search'), isTrue);
        expect(resolver.canAccess('proforma-history'), isFalse);
        expect(resolver.canAccess('expiration-logs'), isFalse);
        expect(resolver.canAccess(RouteNames.imports), isFalse);
      },
    );
  });
}
