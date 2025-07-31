import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';

part 'read_client_catalog_state.dart';

class ReadClientCatalogCubit extends Cubit<ClientCatalogState> {
  ReadClientCatalogCubit(this.clientsRepository) : super(ClientCatalogInitial());

  final ClientsRepository clientsRepository;

  Future<void> loadAllClients() async {
    emit(ClientCatalogLoading());
    try {
      final clients = await clientsRepository.getAllClients();
      emit(ClientCatalogSuccess(clients));
    } catch (error) {
      emit(ClientCatalogError(error.toString()));
    }
  }

  Future<void> searchClientByKeyword(String keyword) async {
    final currentState = state as ClientCatalogSuccess;

    if (keyword.isEmpty) {
      emit(ClientCatalogSuccess(clientsRepository.clients));
      return;
    }

    emit(
      ClientCatalogSearching(
        currentState.clients,
      ),
    );
    try {
      final clients = await clientsRepository.searchClientByKeyword(keyword);
      emit(ClientCatalogSuccess(clients));
    } catch (error) {
      emit(ClientCatalogError(error.toString()));
    }
  }

  Future<void> putClientFirst(ClientInDb client) async {
    final currentState = state as ClientCatalogSuccess;
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
    final currentState = state as ClientCatalogSuccess;
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
    final currentState = state as ClientCatalogSuccess;
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
