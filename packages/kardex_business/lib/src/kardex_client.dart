import 'kardex_client_config.dart';

class KardexClient {
  static KardexClientConfig? _config;

  static void initialize(KardexClientConfig config) {
    _config = config;
  }

  static KardexClientConfig get instance {
    if (_config == null) {
      throw StateError('KardexClient not initialized. Call KardexClient.initialize() first.');
    }
    return _config!;
  }
}
