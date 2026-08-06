import 'package:kardex_business/src/data/api_keys_data_source.dart';
import 'package:kardex_business/src/domain/models/api_key/api_key_model.dart';

class ApiKeysRepository {
  final ApiKeysDataSource apiKeysDataSource;

  ApiKeysRepository(this.apiKeysDataSource);

  List<ApiKeyModel> _apiKeys = [];

  List<ApiKeyModel> get apiKeys => _apiKeys;

  Future<List<ApiKeyModel>> getAllApiKeys() async {
    final results = await apiKeysDataSource.getAllApiKeys();
    _apiKeys = results.map((e) => ApiKeyModel.fromJson(e as Map<String, dynamic>)).toList();
    return _apiKeys;
  }

  Future<ApiKeyModel> createApiKey({
    required String name,
    String serviceType = 'power_bi',
    List<String> scopes = const ['bi:read'],
    String? branchId,
  }) async {
    final body = {
      'name': name,
      'serviceType': serviceType,
      'scopes': scopes,
      '?branchId': branchId,
    };

    final result = await apiKeysDataSource.createApiKey(body);
    final created = ApiKeyModel.fromJson(result);
    _apiKeys.insert(0, created);
    return created;
  }

  Future<ApiKeyModel?> toggleApiKeyStatus(String keyId, bool isActive) async {
    final result = await apiKeysDataSource.toggleApiKeyStatus(keyId, isActive);
    final updated = ApiKeyModel.fromJson(result);
    final index = _apiKeys.indexWhere((k) => k.id == keyId);
    if (index != -1) {
      _apiKeys[index] = updated;
    }
    return updated;
  }

  Future<void> deleteApiKey(String keyId) async {
    await apiKeysDataSource.deleteApiKey(keyId);
    _apiKeys.removeWhere((k) => k.id == keyId);
  }
}
