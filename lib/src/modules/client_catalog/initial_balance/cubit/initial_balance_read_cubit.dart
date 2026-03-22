import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/query_params/client_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';

part 'initial_balance_read_state.dart';

class InitialBalanceReadCubit extends Cubit<InitialBalanceReadState> {
  InitialBalanceReadCubit(this.clientsRepository) : super(InitialBalanceReadInitial());

  final ClientsRepository clientsRepository;

  Future<void> loadClientsWithoutMovements() async {
    emit(InitialBalanceReadLoading());
    try {
      final params = ClientQueryParams()
        ..hasMovements = false
        ..limit = 200;

      final clients = await clientsRepository.getClients(params);
      clients.sort(
        (ClientInDb a, ClientInDb b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );

      emit(InitialBalanceReadSuccess(clients));
    } catch (error) {
      emit(InitialBalanceReadError(error.toString()));
    }
  }

  void searchClientByKeyword(String keyword) {
    if (state is! InitialBalanceReadSuccess) return;
    final currentState = state as InitialBalanceReadSuccess;

    if (keyword.isEmpty) {
      loadClientsWithoutMovements();
      return;
    }

    final filteredClients = currentState.clients.where((c) {
      final queryLower = keyword.toLowerCase();
      final cardId = c.cardId;
      return c.name.toLowerCase().contains(queryLower) ||
          (cardId != null && cardId.toLowerCase().contains(queryLower)) ||
          (c.phone != null && c.phone!.contains(queryLower));
    }).toList();

    emit(InitialBalanceReadSuccess(filteredClients));
  }

  void removeClientFromList(String clientId) {
    if (state is! InitialBalanceReadSuccess) return;

    final currentState = state as InitialBalanceReadSuccess;
    final updatedList = currentState.clients.where((c) => c.id != clientId).toList();

    emit(InitialBalanceReadSuccess(updatedList));
  }
}
