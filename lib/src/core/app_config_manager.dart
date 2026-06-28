import 'dart:convert';

import 'package:kardex_business/kardex_business.dart';

class AppConfigManager with HiveService implements AppConfigStore {
  final _configBox = 'config_box';
  final _configKey = 'config_key';

  static final AppConfigManager _instance = AppConfigManager._internal();
  factory AppConfigManager() => _instance;
  AppConfigManager._internal();

  @override
  Future<void> setConfig(Map<String, dynamic> config) async {
    final jsonString = json.encode(config);
    final box = await getBox(_configBox);
    await box.put(_configKey, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getConfig() async {
    final box = await getBox(_configBox);
    final jsonString = box.get(_configKey);
    if (jsonString == null) return null;
    final config = json.decode(jsonString);
    return config;
  }

  @override
  Future<void> clearConfig() async {
    final box = await getBox(_configBox);
    await box.clear();
  }
}
