import 'dart:convert';

import 'package:kardex_app_front/src/services/hive_service.dart';

class SessionManager with HiveService {
  final _boxName = 'sessionBox';
  final sessionKey = 'session';

  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Future<void> storeSession(Map<String, dynamic> session) async {
    final data = json.encode(session);
    final box = await getBox(_boxName);
    await box.put(sessionKey, data);
  }

  Future<Map?> getSession() async {
    final box = await getBox(_boxName);
    final data = box.get(sessionKey);
    if (data == null) return null;

    final sessionData = json.decode(data);
    return sessionData;
  }

  Future<void> removeSession() async {
    final box = await getBox(_boxName);
    await box.clear();
  }
}
