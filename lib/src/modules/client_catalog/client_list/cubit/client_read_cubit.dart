import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_group_repository.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';

part 'client_read_state.dart';

class ReadClientCubit extends Cubit<ReadClientState> {
  ReadClientCubit(this.clientsRepository, this.clientGroupsRepository) : super(ReadClientInitial());

  final ClientsRepository clientsRepository;
  final ClientGroupsRepository clientGroupsRepository;

  Future<void> loadAllClients() async {
    emit(ReadClientLoading());
    try {
      final result = await Future.wait([
        clientGroupsRepository.getAllClientGroups(),
        clientsRepository.getAllClients(),
      ]);

      final clients = result[1] as List<ClientInDb>;

      emit(ReadClientSuccess(clients));
    } catch (error) {
      emit(ClientReadError(error.toString()));
    }
  }

  Future<void> searchClientByKeyword(String keyword) async {
    final currentState = state as ReadClientSuccess;

    if (keyword.isEmpty) {
      emit(ReadClientSuccess(clientsRepository.clients));
      return;
    }

    emit(
      ReadClientSearching(
        currentState.clients,
      ),
    );
    try {
      final clients = await clientsRepository.searchClientByKeyword(keyword);
      emit(ReadClientSuccess(clients));
    } catch (error) {
      emit(ClientReadError(error.toString()));
    }
  }

  Future<void> putClientFirst(ClientInDb client) async {
    final currentState = state as ReadClientSuccess;
    final freshClientList = clientsRepository.clients;
    if (currentState is HighlightedClient) {
      emit(
        HighlightedClient(
          freshClientList,
          newClients: [client, ...currentState.newClients],
          updatedClients: currentState.updatedClients,
        ),
      );
      return;
    }
    emit(
      HighlightedClient(
        freshClientList,
        newClients: [client],
      ),
    );
  }

  Future<void> markClientUpdated(ClientInDb client) async {
    final currentState = state as ReadClientSuccess;
    final freshClientList = clientsRepository.clients;

    if (currentState is HighlightedClient) {
      emit(
        HighlightedClient(
          freshClientList,
          newClients: currentState.newClients,
          updatedClients: [client, ...currentState.updatedClients],
        ),
      );
      return;
    }
    emit(
      HighlightedClient(
        freshClientList,
        updatedClients: [client],
      ),
    );
  }

  Future<void> refreshClient() async {
    final currentState = state as ReadClientSuccess;
    final freshClientList = clientsRepository.clients;
    if (currentState is HighlightedClient) {
      emit(
        HighlightedClient(
          freshClientList,
          newClients: currentState.newClients,
          updatedClients: currentState.updatedClients,
        ),
      );
      return;
    }
    emit(
      HighlightedClient(
        freshClientList,
      ),
    );
  }
}
