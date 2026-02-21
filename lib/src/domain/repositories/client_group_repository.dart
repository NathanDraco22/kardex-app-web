import 'package:kardex_app_front/src/data/client_group_data_source.dart';
import 'package:kardex_app_front/src/domain/models/client_group/client_group_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ClientGroupsRepository {
  final ClientGroupDataSource clientGroupDataSource;

  ClientGroupsRepository(this.clientGroupDataSource);

  List<ClientGroupInDb> _clientGroups = [];

  List<ClientGroupInDb> get clientGroups => _clientGroups;

  Future<ClientGroupInDb> createClientGroup(CreateClientGroup createGroup) async {
    final result = await clientGroupDataSource.createClientGroup(createGroup.toJson());
    final newGroup = ClientGroupInDb.fromJson(result);
    _clientGroups = [newGroup, ..._clientGroups];
    return newGroup;
  }

  Future<List<ClientGroupInDb>> getAllClientGroups() async {
    final results = await clientGroupDataSource.getAllClientGroups();

    final response = ListResponse<ClientGroupInDb>.fromJson(
      results,
      ClientGroupInDb.fromJson,
    );

    _clientGroups = response.data;
    _clientGroups.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _clientGroups;
  }

  Future<ClientGroupInDb?> getClientGroupById(String groupId) async {
    final result = await clientGroupDataSource.getClientGroupById(groupId);
    if (result == null) return null;
    return ClientGroupInDb.fromJson(result);
  }

  Future<List<ClientGroupInDb>> searchClientGroupByKeywordLocal(String keyword) async {
    final result = _clientGroups
        .where(
          (u) => u.name.toLowerCase().contains(
            keyword.toLowerCase(),
          ),
        )
        .toList();
    return result;
  }

  Future<ClientGroupInDb?> updateClientGroupById(
    String groupId,
    UpdateClientGroup group,
  ) async {
    final result = await clientGroupDataSource.updateClientGroupById(
      groupId,
      group.toJson(),
    );
    if (result == null) return null;

    final updatedGroup = ClientGroupInDb.fromJson(result);
    final index = _clientGroups.indexWhere((u) => u.id == groupId);
    if (index != -1) {
      _clientGroups[index] = updatedGroup;
    }
    return updatedGroup;
  }

  Future<ClientGroupInDb?> deleteClientGroupById(String groupId) async {
    final result = await clientGroupDataSource.deleteClientGroupById(groupId);
    if (result == null) return null;

    final deletedGroup = ClientGroupInDb.fromJson(result);
    _clientGroups.removeWhere((u) => u.id == groupId);
    return deletedGroup;
  }
}
