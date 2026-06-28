import 'dart:convert';

import 'package:kardex_business/kardex_business.dart';

class SessionManager with HiveService implements SessionStore {
  final _boxName = 'sessionBox';
  final sessionKey = 'session';

  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  @override
  Future<void> storeSession(Map<String, dynamic> session) async {
    final data = json.encode(session);
    final box = await getBox(_boxName);
    await box.put(sessionKey, data);
  }

  @override
  Future<Map<String, dynamic>?> getSession() async {
    final box = await getBox(_boxName);
    final data = box.get(sessionKey);
    if (data == null) return null;

    final sessionData = json.decode(data) as Map<String, dynamic>;
    return sessionData;
  }

  @override
  Future<void> removeSession() async {
    final box = await getBox(_boxName);
    await box.clear();
  }
}
