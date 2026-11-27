import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepository appSettingsRepository;

  AppSettingsCubit(this.appSettingsRepository) : super(AppSettingsInitial()) {
    NumberFormatter.configureCurrencyResolver(() => policy.currency);
    NumberFormatter.configureSecondaryCurrencyResolver(
      _secondaryCurrencyConfig,
    );
    InvoiceRounding.configureEnabledResolver(
      () => policy.roundUpInvoiceTotals,
    );
    BaseBranch.configureTaxIdLabelResolver(() => policy.taxIdLabel);
    BaseInvoice.configureDisplayConfigResolver(
      () => policy.invoiceDisplayConfig,
    );
  }

  /// Decisiones derivadas de la configuración vigente.
  ///
  /// Es una vista calculada de [currentSettings]; no mantiene estado propio y
  /// sigue las mismas transiciones que el cubit.
  AppSettingsPolicy get policy => AppSettingsPolicy(currentSettings ?? AppSettingModel.defaults);

  AppSettingModel? get currentSettings {
    final current = state;
    if (current is AppSettingsLoaded) return current.settings;
    if (current is AppSettingsSaving) return current.currentSettings;
    if (current is AppSettingsError) {
      return current.lastSettings ?? appSettingsRepository.currentAppSettings;
    }
    return appSettingsRepository.currentAppSettings;
  }

  SecondaryCurrencyConfig? _secondaryCurrencyConfig() {
    final display = policy.invoiceSecondaryCurrencyDisplay;
    if (display == null) return null;
    return SecondaryCurrencyConfig(
      currency: display.secondaryCurrency,
      exchangeRate: display.exchangeRate,
      showInvoiceTotal: true,
    );
  }

  Future<void> loadSettings() async {
    emit(AppSettingsLoading());
    try {
      final settings = await appSettingsRepository.getCurrentAppSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
  }

  /// Descarta la configuración en memoria al salir o cambiar de negocio.
  void clear() {
    appSettingsRepository.clearCurrentAppSettings();
    emit(AppSettingsInitial());
  }

  Future<bool> updateSettings(UpdateAppSetting update) async {
    var current = currentSettings;

    if (current == null) {
      try {
        current = await appSettingsRepository.getCurrentAppSettings();
      } catch (_) {}
    }

    if (current == null) {
      emit(AppSettingsError("No hay configuración activa cargada"));
      return false;
    }

    emit(AppSettingsSaving(current));
    try {
      final updated = await appSettingsRepository.updateAppSettings(
        current.id,
        update,
      );
      emit(AppSettingsLoaded(updated));
      return true;
    } catch (e) {
      emit(AppSettingsError(e.toString(), lastSettings: current));
      return false;
    }
  }

  @override
  Future<void> close() async {
    NumberFormatter.configureCurrencyResolver(null);
    NumberFormatter.configureSecondaryCurrencyResolver(null);
    InvoiceRounding.configureEnabledResolver(null);
    BaseInvoice.configureDisplayConfigResolver(null);
    BaseBranch.configureTaxIdLabelResolver(null);
    await super.close();
  }
}
