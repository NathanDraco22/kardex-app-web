import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

abstract class ApiKeysState {}

class ApiKeysInitial extends ApiKeysState {}

class ApiKeysLoading extends ApiKeysState {}

class ApiKeysLoaded extends ApiKeysState {
  final List<ApiKeyModel> apiKeys;
  ApiKeysLoaded(this.apiKeys);
}

class ApiKeysError extends ApiKeysState {
  final String message;
  ApiKeysError(this.message);
}

class ApiKeysCubit extends Cubit<ApiKeysState> {
  final ApiKeysRepository apiKeysRepository;

  ApiKeysCubit(this.apiKeysRepository) : super(ApiKeysInitial());

  Future<void> loadApiKeys() async {
    emit(ApiKeysLoading());
    try {
      final keys = await apiKeysRepository.getAllApiKeys();
      emit(ApiKeysLoaded(keys));
    } catch (e) {
      emit(ApiKeysError(e.toString()));
    }
  }

  Future<ApiKeyModel?> createApiKey({
    required String name,
    String serviceType = 'power_bi',
    List<String> scopes = const ['bi:read'],
    String? branchId,
  }) async {
    try {
      final created = await apiKeysRepository.createApiKey(
        name: name,
        serviceType: serviceType,
        scopes: scopes,
        branchId: branchId,
      );
      await loadApiKeys();
      return created;
    } catch (e) {
      emit(ApiKeysError("Error creando llave: ${e.toString()}"));
      return null;
    }
  }

  Future<void> toggleApiKeyStatus(String keyId, bool isActive) async {
    try {
      await apiKeysRepository.toggleApiKeyStatus(keyId, isActive);
      await loadApiKeys();
    } catch (e) {
      emit(ApiKeysError("Error al cambiar estado: ${e.toString()}"));
    }
  }

  Future<void> deleteApiKey(String keyId) async {
    try {
      await apiKeysRepository.deleteApiKey(keyId);
      await loadApiKeys();
    } catch (e) {
      emit(ApiKeysError("Error al eliminar llave: ${e.toString()}"));
    }
  }
}
