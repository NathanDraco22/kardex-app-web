import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository() : super(AppSettingsDataSource());

  AppSettingModel? stored;
  AppSettingModel? nextSettings;
  Object? updateError;
  Completer<AppSettingModel>? updateCompleter;

  @override
  AppSettingModel? get currentAppSettings => stored;

  @override
  void clearCurrentAppSettings() {
    stored = null;
  }

  @override
  Future<AppSettingModel> getCurrentAppSettings() async {
    final current = stored;
    if (current == null) {
      throw Exception('Sin configuración');
    }
    return current;
  }

  @override
  Future<AppSettingModel> updateAppSettings(
    String appSettingId,
    UpdateAppSetting body,
  ) async {
    final completer = updateCompleter;
    if (completer != null) {
      return completer.future;
    }
    final error = updateError;
    if (error != null) {
      throw error;
    }
    stored = nextSettings ?? stored;
    return stored!;
  }
}

AppSettingModel _settings({
  required String id,
  required bool useShifts,
}) {
  return AppSettingModel(
    id: id,
    createdAt: 0,
    useShifts: useShifts,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync(
      'app_settings_cubit_policy_test_',
    );
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } on FileSystemException {
      // En Windows el archivo de Hive puede seguir bloqueado unos instantes.
    }
  });

  group('AppSettingsCubit.policy y transiciones de estado', () {
    late _FakeAppSettingsRepository repository;
    late AppSettingsCubit cubit;

    setUp(() {
      repository = _FakeAppSettingsRepository();
      cubit = AppSettingsCubit(repository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('usa defaults cuando todavía no hay configuración', () {
      expect(cubit.policy.useShifts, isFalse);
      expect(cubit.policy.convertedOrderShiftPolicy, ConvertedOrderShiftPolicy.never);
    });

    test('adopta la configuración después de loadSettings', () async {
      repository.stored = _settings(id: 'a', useShifts: true);

      await cubit.loadSettings();

      expect(cubit.state, isA<AppSettingsLoaded>());
      expect(cubit.policy.useShifts, isTrue);
    });

    test('durante Saving conserva la configuración anterior', () async {
      repository.stored = _settings(id: 'a', useShifts: true);
      await cubit.loadSettings();

      final completer = Completer<AppSettingModel>();
      repository.updateCompleter = completer;

      final future = cubit.updateSettings(
        const UpdateAppSetting(useShifts: false),
      );

      expect(cubit.state, isA<AppSettingsSaving>());
      expect(cubit.policy.useShifts, isTrue);

      completer.complete(_settings(id: 'a', useShifts: false));
      await future;

      expect(cubit.state, isA<AppSettingsLoaded>());
      expect(cubit.policy.useShifts, isFalse);
    });

    test('si falla el guardado conserva lastSettings', () async {
      repository.stored = _settings(id: 'a', useShifts: true);
      await cubit.loadSettings();

      repository.updateError = Exception('fallo de red');

      final success = await cubit.updateSettings(
        const UpdateAppSetting(useShifts: false),
      );

      expect(success, isFalse);
      expect(cubit.state, isA<AppSettingsError>());
      expect(cubit.policy.useShifts, isTrue);
    });

    test('clear vuelve a los valores por defecto', () async {
      repository.stored = _settings(id: 'a', useShifts: true);
      await cubit.loadSettings();

      cubit.clear();

      expect(cubit.state, isA<AppSettingsInitial>());
      expect(cubit.policy.useShifts, isFalse);
      expect(cubit.policy.convertedOrderShiftPolicy, ConvertedOrderShiftPolicy.never);
    });

    test('los resolvers globales leen la policy vigente', () async {
      repository.stored = const AppSettingModel(
        id: 'a',
        createdAt: 0,
        roundUpInvoiceTotals: true,
        showInvoiceItemsSummary: true,
        taxIdLabel: 'NIT',
        showInvoiceTotalInSecondaryCurrency: true,
        exchangeRate: 36,
      );
      await cubit.loadSettings();

      expect(InvoiceRounding.isEnabled, isTrue);
      expect(BaseInvoice.displayConfig.showItemsSummary, isTrue);
      expect(BaseBranch.activeTaxIdLabel, 'NIT');
      expect(NumberFormatter.convertInvoiceTotalToSecondaryMoney(3600), isNotNull);
    });
  });
}
