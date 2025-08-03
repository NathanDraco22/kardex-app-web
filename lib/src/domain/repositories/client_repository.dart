import 'package:kardex_app_front/src/data/client_data_source.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ClientsRepository {
  final ClientsDataSource clientsDataSource;

  ClientsRepository(this.clientsDataSource);

  List<ClientInDb> _clients = [];

  List<ClientInDb> get clients => _clients;

  Future<ClientInDb> createClient(CreateClient createClient) async {
    final result = await clientsDataSource.createClient(createClient.toJson());
    final newClient = ClientInDb.fromJson(result);
    _clients = [newClient, ...clients];
    return newClient;
  }

  Future<List<ClientInDb>> getAllClients() async {
    final results = await clientsDataSource.getAllClients();

    final responseModel = ListResponse<ClientInDb>.fromJson(
      results,
      ClientInDb.fromJson,
    );

    _clients = responseModel.data;
    _clients.sort(
      (ClientInDb a, ClientInDb b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return _clients;
  }

  Future<ClientInDb?> getClientById(String clientId) async {
    final result = await clientsDataSource.getClientById(clientId);

    if (result == null) {
      return null;
    }

    return ClientInDb.fromJson(result);
  }

  Future<List<ClientInDb>> searchClientByKeyword(String keyword) async {
    final result = await clientsDataSource.searchClientByKeyword(keyword);

    final responseModel = ListResponse<ClientInDb>.fromJson(
      result,
      ClientInDb.fromJson,
    );
    return responseModel.data;
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

    final updatedClient = ClientInDb.fromJson(result);

    final index = _clients.indexWhere((client) => client.id == clientId);
    _clients[index] = updatedClient;
    return updatedClient;
  }

  Future<ClientInDb?> deleteClientById(String clientId) async {
    final result = await clientsDataSource.deleteClientById(clientId);
    if (result == null) {
      return null;
    }
    final deletedClient = ClientInDb.fromJson(result);
    _clients.removeWhere((client) => client.id == clientId);
    return deletedClient;
  }
}
