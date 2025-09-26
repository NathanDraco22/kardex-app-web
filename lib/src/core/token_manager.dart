import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String _currentSessionToken = "";

  void storeToken(String token) {
    _currentSessionToken = token;
  }

  String getToken() {
    if (_currentSessionToken.isEmpty) {
      throw Exception("Token not found");
    }
    return _currentSessionToken;
  }

  void removeToken() => _currentSessionToken = "";

  bool isTokenGotExpired(String token) {
    late JWT decodedToken;
    try {
      decodedToken = JWT.decode(token);
    } catch (e) {
      return false;
    }
    final expiration = decodedToken.payload["exp"] as int?;
    if (expiration == null) return false;
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(
      expiration * 1000,
      isUtc: true,
    );
    final nowUtc = DateTime.now().toUtc();
    final expirationLimit = expirationDate.subtract(const Duration(hours: 1));
    if (nowUtc.isAfter(expirationLimit)) return true;
    return false;
  }
}
