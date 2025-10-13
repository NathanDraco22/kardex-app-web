import 'dart:convert';

import 'package:kardex_app_front/src/services/hive_service.dart';

class AppConfigManager with HiveService {
  final _configBox = 'config_box';
  final _configKey = 'config_key';

  static final AppConfigManager _instance = AppConfigManager._internal();
  factory AppConfigManager() => _instance;
  AppConfigManager._internal();

  Future<void> setConfig(Map<String, dynamic> config) async {
    final jsonString = json.encode(config);
    final box = await getBox(_configBox);
    await box.put(_configKey, jsonString);
  }

  Future<Map<String, dynamic>?> getConfig() async {
    final box = await getBox(_configBox);
    final jsonString = box.get(_configKey);
    if (jsonString == null) return null;
    final config = json.decode(jsonString);
    return config;
  }

  Future<void> clearConfig() async {
    final box = await getBox(_configBox);
    await box.clear();
  }
}
