import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/app_settings/app_settings_screen.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  _FakeAppSettingsRepository(this._settings);

  AppSettingModel _settings;
  UpdateAppSetting? lastUpdate;

  @override
  AppSettingModel? get currentAppSettings => _settings;

  @override
  Future<AppSettingModel> getCurrentAppSettings() async => _settings;

  @override
  Future<AppSettingModel> updateAppSettings(
    String appSettingId,
    UpdateAppSetting body,
  ) async {
    lastUpdate = body;
    _settings = _settings.copyWith(
      allowCancellationsOutsideShift: body.allowCancellationsOutsideShift ?? _settings.allowCancellationsOutsideShift,
      roundUpInvoiceTotals: body.roundUpInvoiceTotals ?? _settings.roundUpInvoiceTotals,
      useAbonoReceivedAmount: body.useAbonoReceivedAmount ?? _settings.useAbonoReceivedAmount,
    );
    return _settings;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

void main() {
  tearDown(() async {
    InvoiceRounding.configureEnabledResolver(null);
    await getIt.reset();
  });

  testWidgets(
    'AppSettingsScreen muestra, sincroniza y guarda los switches de anulación y redondeo',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = _FakeAppSettingsRepository(
        const AppSettingModel(id: 'Default', createdAt: 0),
      );
      final appSettingsCubit = AppSettingsCubit(repository);
      getIt.registerSingleton<AppSettingsCubit>(appSettingsCubit);
      appSettingsCubit.emit(
        AppSettingsLoaded(repository.currentAppSettings!),
      );
      getIt.registerSingleton<AuthCubit>(
        AuthCubit(
          authRepository: _FakeAuthRepository(),
          branchesRepository: _FakeBranchesRepository(),
          servinRepository: _FakeServinRepository(),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(home: AppSettingsScreen()),
      );
      await tester.pumpAndSettle();

      final switchTitle = find.text(
        'Permitir Anular Facturas y Recibos Fuera de Turno',
      );
      await tester.scrollUntilVisible(
        switchTitle,
        500,
        scrollable: find.byType(Scrollable).first,
      );

      final tileFinder = find.ancestor(
        of: switchTitle,
        matching: find.byType(SwitchListTile),
      );
      expect(tileFinder, findsOneWidget);
      expect(tester.widget<SwitchListTile>(tileFinder).value, isFalse);

      await tester.tap(switchTitle);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(tileFinder).value, isTrue);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(repository.lastUpdate, isNotNull);
      expect(repository.lastUpdate!.allowCancellationsOutsideShift, isTrue);
      // PATCH parcial: no reenvía campos que no cambiaron.
      expect(repository.lastUpdate!.useOrders, isNull);
      expect(repository.lastUpdate!.useShifts, isNull);

      final roundingTitle = find.text('Redondear a la Alta en Facturas');
      await tester.scrollUntilVisible(
        roundingTitle,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      final roundingTile = find.ancestor(
        of: roundingTitle,
        matching: find.byType(SwitchListTile),
      );
      expect(roundingTile, findsOneWidget);
      expect(tester.widget<SwitchListTile>(roundingTile).value, isFalse);

      await tester.tap(roundingTitle);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(roundingTile).value, isTrue);

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repository.lastUpdate!.roundUpInvoiceTotals, isTrue);

      final abonoReceivedTitle = find.text(
        'Capturar dinero recibido y cambio en abonos',
      );
      await tester.scrollUntilVisible(
        abonoReceivedTitle,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      final abonoReceivedTile = find.ancestor(
        of: abonoReceivedTitle,
        matching: find.byType(SwitchListTile),
      );
      expect(abonoReceivedTile, findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(abonoReceivedTile).value,
        isFalse,
      );

      await tester.tap(abonoReceivedTitle);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SwitchListTile>(abonoReceivedTile).value,
        isTrue,
      );

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repository.lastUpdate!.useAbonoReceivedAmount, isTrue);
    },
  );
}
