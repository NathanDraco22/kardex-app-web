import 'package:kardex_app_front/config/app_env.dart';
import 'package:kardex_app_front/src/core/token_manager.dart';

class HttpTools {
  static String baseUrl = AppEnv.serverUrl;
  static const String _api = "/api";

  static String practiceUrl = "";

  static Uri generateUri(String path, {int version = 1, Map<String, String>? queryParameters}) {
    assert(path.startsWith("/"));

    if (practiceUrl.isNotEmpty) {
      baseUrl = practiceUrl;
    }

    final decodedBase = Uri.parse(baseUrl);
    final fullPath = "$_api/v$version$path";

    if (decodedBase.scheme == "https") {
      return Uri.https(decodedBase.authority, fullPath, queryParameters);
    } else {
      final result = Uri.http(
        "${decodedBase.host}:${decodedBase.port}",
        fullPath,
        queryParameters,
      );

      return result;
    }
  }

  static Map<String, String> generateAuthHeaders() {
    final token = TokenManager().getToken();
    return {
      "Authorization": "Bearer $token",
      "X-Agent": "Neptuno",
    };
  }
}
