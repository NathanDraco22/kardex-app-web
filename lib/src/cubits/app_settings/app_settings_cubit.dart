import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepository appSettingsRepository;

  AppSettingsCubit(this.appSettingsRepository) : super(AppSettingsInitial());

  AppSettingModel? get currentSettings {
    if (state is AppSettingsLoaded) return (state as AppSettingsLoaded).settings;
    if (state is AppSettingsSaving) return (state as AppSettingsSaving).currentSettings;
    return appSettingsRepository.currentAppSettings;
  }

  bool get useExpirationDates => currentSettings?.useExpirationDates ?? true;
  bool get useOrders => currentSettings?.useOrders ?? true;
  bool get useQuotations => currentSettings?.useQuotations ?? true;
  bool get useDefaultProfitMargin => currentSettings?.useDefaultProfitMargin ?? false;
  double get defaultProfitMargin => currentSettings?.defaultProfitMargin ?? 20.0;
  bool get allowNegativeStock => currentSettings?.allowNegativeStock ?? false;
  bool get alertMinStock => currentSettings?.alertMinStock ?? true;
  int get defaultPaymentTermDays => currentSettings?.defaultPaymentTermDays ?? 30;
  bool get useHoldSales => currentSettings?.useHoldSales ?? true;

  Future<void> loadSettings() async {
    emit(AppSettingsLoading());
    try {
      final settings = await appSettingsRepository.getCurrentAppSettings();
      emit(AppSettingsLoaded(settings));
    } catch (e) {
      emit(AppSettingsError(e.toString()));
    }
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
}
