import 'package:kardex_app_front/src/data/client_data_source.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/client/responses.dart';

class ClientsRepository {
  final ClientsDataSource clientsDataSource;

  ClientsRepository(this.clientsDataSource);

  Future<ClientInDb> createClient(CreateClient createClient) async {
    final result = await clientsDataSource.createClient(createClient.toJson());
    return ClientInDb.fromJson(result);
  }

  Future<List<ClientInDb>> getAllClients() async {
    final results = await clientsDataSource.getAllClients();
    final models = ClientsResponseModel.fromJson(results);
    return models.data;
  }

  Future<ClientInDb?> getClientById(String clientId) async {
    final result = await clientsDataSource.getClientById(clientId);

    if (result == null) {
      return null;
    }

    return ClientInDb.fromJson(result);
  }

  Future<ClientInDb?> updateClientById(
    String clientId,
    UpdateClient client,
  ) async {
    final result = await clientsDataSource.updateClientById(
      clientId,
      client.toJson(),
    );

    if (result == null) {
      return null;
    }

    return ClientInDb.fromJson(result);
  }
}
