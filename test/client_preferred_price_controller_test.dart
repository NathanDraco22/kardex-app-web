import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/src/modules/commercial/client_invoices/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  _FakeAppSettingsRepository([this.settings]);

  AppSettingModel? settings;

  @override
  AppSettingModel? get currentAppSettings => settings;

  @override
  void clearCurrentAppSettings() {}

  @override
  Future<AppSettingModel> getCurrentAppSettings() async {
    final current = settings;
    if (current == null) throw Exception('Sin configuración');
    return current;
  }

  @override
  Future<AppSettingModel> updateAppSettings(
    String appSettingId,
    UpdateAppSetting body,
  ) async {
    final current = settings;
    if (current == null) throw Exception('Sin configuración');
    return current;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppSettingsCubit _registerCubit(AppSettingsCubit cubit) {
  getIt.registerSingleton<AppSettingsCubit>(cubit);

  addTearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  return cubit;
}

void _registerSettings({required bool enabled}) {
  final repository = _FakeAppSettingsRepository(
    AppSettingModel(
      id: 'test',
      createdAt: 0,
      useClientPreferredPrices: enabled,
    ),
  );
  final cubit = AppSettingsCubit(repository);
  cubit.emit(AppSettingsLoaded(repository.settings!));
  _registerCubit(cubit);
}

AppSettingsCubit _registerUnloadedSettings() {
  final repository = _FakeAppSettingsRepository();
  return _registerCubit(AppSettingsCubit(repository));
}

ProductInDbInBranch _product({String id = 'p1'}) {
  final now = DateTime(2026, 11, 28);
  return ProductInDbInBranch(
    id: id,
    name: 'Producto $id',
    unitName: 'UND',
    categoryName: 'General',
    tags: const [],
    hasIva: false,
    extraUnits: const [],
    defaultUnitIndex: 0,
    wholesaleUnitIndex: 0,
    priceUnitFactor: 1,
    createdAt: now,
    account: ProductAccountInDb(
      branchId: 'b1',
      productId: id,
      currentStock: 10,
      averageCost: 500,
      lastCost: 500,
      maximumCost: 500,
      createdAt: now,
    ),
    saleProfile: ProductSaleProfileInDb(
      branchId: 'b1',
      productId: id,
      salePrice: 1000,
      salePrice2: 2000,
      salePrice3: 3000,
      salePrice4: 4000,
    ),
  );
}

CommercialProductResult _cartItem(ProductInDbInBranch product) {
  final item = CommercialProductResult(
    product: product,
    defaultPriceLevel: 1,
  );
  item.quantity = 1;
  return item;
}

ClientInDb _client(int level, {bool usePreferredPrice = true}) {
  return ClientInDb(
    id: 'c1',
    name: 'Cliente',
    createdAt: DateTime(2026, 11, 28),
    usePreferredPrice: usePreferredPrice,
    defaultPriceLevel: level,
  );
}

void main() {
  group('SaleTerminalViewController', () {
    test('aplica el nivel del cliente cuando la función está activa', () async {
      _registerSettings(enabled: true);
      final controller = SaleTerminalViewController();
      addTearDown(controller.dispose);
      final product = _product();
      controller.addItem(_cartItem(product));

      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 2);
      expect(controller.items.single.selectedPriceLevel, 2);
      expect(controller.items.single.newPrice, 2000);
    });

    test('Sin Preferencia no cambia el nivel ni los precios', () async {
      _registerSettings(enabled: true);
      final controller = SaleTerminalViewController();
      addTearDown(controller.dispose);
      final product = _product();
      controller.addItem(_cartItem(product));
      controller.selectedPriceLevel = 2;

      controller.selectedClient = _client(1, usePreferredPrice: false);

      expect(controller.selectedPriceLevel, 2);
      expect(controller.items.single.selectedPriceLevel, 2);
      expect(controller.items.single.newPrice, 2000);
    });

    test('con la función apagada no aplica la preferencia', () async {
      _registerSettings(enabled: false);
      final controller = SaleTerminalViewController();
      addTearDown(controller.dispose);
      final product = _product();
      controller.addItem(_cartItem(product));

      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 1);
      expect(controller.items.single.selectedPriceLevel, 1);
      expect(controller.items.single.newPrice, 1000);
    });

    test('no aplica preferencia hasta que los ajustes estén cargados', () async {
      final cubit = _registerUnloadedSettings();
      final controller = SaleTerminalViewController();
      addTearDown(controller.dispose);
      final product = _product();
      controller.addItem(_cartItem(product));

      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 1);
      expect(controller.items.single.selectedPriceLevel, 1);
      expect(controller.items.single.newPrice, 1000);

      cubit.emit(
        AppSettingsLoaded(const AppSettingModel(id: 'test', createdAt: 0)),
      );
      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 2);
      expect(controller.items.single.selectedPriceLevel, 2);
      expect(controller.items.single.newPrice, 2000);
    });
  });

  group('ClientInvoiceViewController', () {
    test('aplica el nivel del cliente y reprecia los ítems', () async {
      _registerSettings(enabled: true);
      final controller = ClientInvoiceViewController();
      final product = _product();
      controller.addItem(_cartItem(product));
      var pricesChanged = 0;
      controller.onPricesChanged = () => pricesChanged++;

      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 2);
      expect(controller.items.single.selectedPriceLevel, 2);
      expect(controller.items.single.newPrice, 2000);
      expect(pricesChanged, 1);
    });

    test('Sin Preferencia conserva el nivel para productos nuevos', () async {
      _registerSettings(enabled: true);
      final controller = ClientInvoiceViewController();
      final product = _product();
      controller.addItem(_cartItem(product));
      controller.selectedClient = _client(2);

      controller.selectedClient = _client(1, usePreferredPrice: false);

      expect(controller.selectedPriceLevel, 2);
      expect(controller.items.single.newPrice, 2000);

      final newItem = CommercialProductResult(
        product: _product(id: 'p2'),
        defaultPriceLevel: controller.selectedPriceLevel,
      );
      newItem.quantity = 1;
      controller.addItem(newItem);

      expect(controller.items.last.newPrice, 2000);
      expect(controller.items.last.selectedPriceLevel, 2);
    });

    test('con la función apagada no aplica la preferencia', () async {
      _registerSettings(enabled: false);
      final controller = ClientInvoiceViewController();
      final product = _product();
      controller.addItem(_cartItem(product));
      var pricesChanged = 0;
      controller.onPricesChanged = () => pricesChanged++;

      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 1);
      expect(controller.items.single.selectedPriceLevel, 1);
      expect(controller.items.single.newPrice, 1000);
      expect(pricesChanged, 0);
    });

    test('no reprecia hasta que los ajustes estén cargados', () async {
      final cubit = _registerUnloadedSettings();
      final controller = ClientInvoiceViewController();
      final product = _product();
      controller.addItem(_cartItem(product));
      var pricesChanged = 0;
      controller.onPricesChanged = () => pricesChanged++;

      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 1);
      expect(controller.items.single.selectedPriceLevel, 1);
      expect(controller.items.single.newPrice, 1000);
      expect(pricesChanged, 0);

      cubit.emit(
        AppSettingsLoaded(const AppSettingModel(id: 'test', createdAt: 0)),
      );
      controller.selectedClient = _client(2);

      expect(controller.selectedPriceLevel, 2);
      expect(controller.items.single.selectedPriceLevel, 2);
      expect(controller.items.single.newPrice, 2000);
      expect(pricesChanged, 1);
    });

    test('clear reinicia el nivel a 1', () async {
      _registerSettings(enabled: true);
      final controller = ClientInvoiceViewController();
      controller.selectedClient = _client(3);
      expect(controller.selectedPriceLevel, 3);

      controller.clear();

      expect(controller.selectedPriceLevel, 1);
      expect(controller.selectedClient, isNull);
    });
  });
}
