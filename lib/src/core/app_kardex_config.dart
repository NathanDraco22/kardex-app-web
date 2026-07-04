import 'package:kardex_app_front/config/app_env.dart';
import 'package:kardex_business/kardex_business.dart';

class AppKardexConfig implements KardexClientConfig {
  static final AppKardexConfig _instance = AppKardexConfig._();
  factory AppKardexConfig() => _instance;
  AppKardexConfig._();

  String _baseUrl = AppEnv.serverUrl;
  String _practiceUrl = "";
  String? _servinNickname;
  String? _branchId;

  @override
  String get baseUrl => _baseUrl;

  @override
  String get practiceUrl => _practiceUrl;

  @override
  String get authToken => TokenManager().getToken();

  @override
  String? get servinNickname => _servinNickname;

  @override
  String? get branchId => _branchId;

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  void setPracticeUrl(String url) {
    _practiceUrl = url;
  }

  void setServinNickname(String? nickname) {
    _servinNickname = nickname;
  }

  void setBranchId(String? id) {
    _branchId = id;
  }
}
