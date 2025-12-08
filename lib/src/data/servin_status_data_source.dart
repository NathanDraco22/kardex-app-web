import 'package:kardex_app_front/src/services/http_service.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

class ServinStatusDataSource with HttpService {
  ServinStatusDataSource._();
  static final ServinStatusDataSource instance = ServinStatusDataSource._();
  factory ServinStatusDataSource() {
    return instance;
  }

  final _endpoint = "auths/servin-status";

  Future<Map<String, dynamic>> getServinStatus() async {
    final uri = HttpTools.generateUri(_endpoint);
    final res = await getQuery(uri);
    return res;
  }
}
