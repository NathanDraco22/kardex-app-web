import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'client_read_state.dart';

class ReadClientCubit extends Cubit<ReadClientState> {
  ReadClientCubit(this.clientsRepository) : super(ReadClientInitial());

  final ClientsRepository clientsRepository;

  int _calculateTotal(List<ClientInDb> list) {
    return list.fold<int>(0, (sum, client) => sum + client.balance);
  }

  int get cachedTotalBalance => _calculateTotal(clientsRepository.clients);

  Future<void> loadAllClients() async {
    emit(ReadClientLoading());
    try {
      final clients = await clientsRepository.getAllClients();
      final total = _calculateTotal(clients);
      emit(ReadClientSuccess(clients, totalBalance: total));
    } catch (error) {
      emit(ClientReadError(error.toString()));
    }
  }

  Future<void> searchClientByKeyword(String keyword) async {
    final currentTotal = state is ReadClientSuccess
        ? (state as ReadClientSuccess).totalBalance
        : cachedTotalBalance;

    if (keyword.isEmpty) {
      emit(
        ReadClientSuccess(
          clientsRepository.clients,
          totalBalance: cachedTotalBalance,
          isSearchActive: false,
        ),
      );
      return;
    }

    final currentClients = state is ReadClientSuccess
        ? (state as ReadClientSuccess).clients
        : clientsRepository.clients;

    emit(
      ReadClientSearching(
        currentClients,
        totalBalance: currentTotal,
      ),
    );
    try {
      final clients = await clientsRepository.searchClientByKeyword(keyword);
      emit(
        ReadClientSuccess(
          clients,
          totalBalance: currentTotal,
          isSearchActive: true,
        ),
      );
    } catch (error) {
      emit(ClientReadError(error.toString()));
    }
  }

  Future<void> putClientFirst(ClientInDb client) async {
    final currentState = state as ReadClientSuccess;
    final freshClientList = clientsRepository.clients;
    final total = _calculateTotal(freshClientList);
    if (currentState is HighlightedClient) {
      emit(
        HighlightedClient(
          freshClientList,
          totalBalance: total,
          newClients: [client, ...currentState.newClients],
          updatedClients: currentState.updatedClients,
        ),
      );
      return;
    }
    emit(
      HighlightedClient(
        freshClientList,
        totalBalance: total,
        newClients: [client],
      ),
    );
  }

  Future<void> markClientUpdated(ClientInDb client) async {
    final currentState = state as ReadClientSuccess;
    final freshClientList = clientsRepository.clients;
    final total = _calculateTotal(freshClientList);

    if (currentState is HighlightedClient) {
      emit(
        HighlightedClient(
          freshClientList,
          totalBalance: total,
          newClients: currentState.newClients,
          updatedClients: [client, ...currentState.updatedClients],
        ),
      );
      return;
    }
    emit(
      HighlightedClient(
        freshClientList,
        totalBalance: total,
        updatedClients: [client],
      ),
    );
  }

  Future<void> refreshClient() async {
    final currentState = state as ReadClientSuccess;
    final freshClientList = clientsRepository.clients;
    final total = _calculateTotal(freshClientList);
    if (currentState is HighlightedClient) {
      emit(
        HighlightedClient(
          freshClientList,
          totalBalance: total,
          newClients: currentState.newClients,
          updatedClients: currentState.updatedClients,
        ),
      );
      return;
    }
    emit(
      HighlightedClient(
        freshClientList,
        totalBalance: total,
      ),
    );
  }
}
