import 'package:kardex_business/kardex_business.dart';

sealed class AppSettingsState {}

class AppSettingsInitial extends AppSettingsState {}

class AppSettingsLoading extends AppSettingsState {}

class AppSettingsLoaded extends AppSettingsState {
  final AppSettingModel settings;
  AppSettingsLoaded(this.settings);
}

class AppSettingsSaving extends AppSettingsState {
  final AppSettingModel currentSettings;
  AppSettingsSaving(this.currentSettings);
}

class AppSettingsError extends AppSettingsState {
  final String message;
  final AppSettingModel? lastSettings;
  AppSettingsError(this.message, {this.lastSettings});
}
