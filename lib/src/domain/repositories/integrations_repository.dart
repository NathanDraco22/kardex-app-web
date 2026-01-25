import 'package:kardex_app_front/src/data/integrations_data_source.dart';
import 'package:kardex_app_front/src/domain/models/integration/integration_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class IntegrationsRepository {
  final IntegrationsDataSource integrationsDataSource;

  IntegrationsRepository(this.integrationsDataSource);

  List<IntegrationModel> _integrations = [];

  List<IntegrationModel> get integrations => _integrations;

  Future<List<IntegrationModel>> getAllIntegrations() async {
    final results = await integrationsDataSource.getAllIntegrations();
    final response = ListResponse<IntegrationModel>.fromJson(
      results,
      IntegrationModel.fromJson,
    );

    _integrations = response.data;
    return _integrations;
  }

  Future<IntegrationModel?> getIntegrationById(String integrationId) async {
    final result = await integrationsDataSource.getIntegrationById(integrationId);
    if (result == null) return null;
    return IntegrationModel.fromJson(result);
  }

  Future<IntegrationModel?> updateIntegrationById(
    String integrationId,
    UpdateIntegration body,
  ) async {
    final result = await integrationsDataSource.updateIntegrationById(
      integrationId,
      body.toJson(),
    );
    if (result == null) return null;

    final updatedIntegration = IntegrationModel.fromJson(result);
    final index = _integrations.indexWhere((i) => i.id == integrationId);
    if (index != -1) {
      _integrations[index] = updatedIntegration;
    }
    return updatedIntegration;
  }

  Future<void> sendTelegramTestNotification() async {
    await integrationsDataSource.sendTelegramTestNotification();
  }
}
