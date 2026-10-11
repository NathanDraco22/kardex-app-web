import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  final AppSettingsRepository appSettingsRepository;

  AppSettingsCubit(this.appSettingsRepository) : super(AppSettingsInitial());

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
    final current = state is AppSettingsLoaded
        ? (state as AppSettingsLoaded).settings
        : state is AppSettingsSaving
            ? (state as AppSettingsSaving).currentSettings
            : appSettingsRepository.currentAppSettings;

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
