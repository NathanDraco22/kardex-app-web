import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/query_params/client_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';

part 'read_pending_client_state.dart';

class ReadPendingClientCubit extends Cubit<ReadPendingClientState> {
  ReadPendingClientCubit(this.clientRepository) : super(ReadPendingClientInitial());

  final ClientsRepository clientRepository;

  final clientQueryParams = ClientQueryParams();

  bool _isLastPage = false;

  Future<void> loadPendingClients() async {
    emit(ReadPendingClientLoading());
    try {
      final clients = await clientRepository.getClientWithBalance(clientQueryParams);

      clientQueryParams.offset += clients.length;
      if (clients.length < clientQueryParams.limit) _isLastPage = true;

      emit(ReadPendingClientSuccess(clients));
    } catch (error) {
      emit(ReadPendingClientError(error.toString()));
    }
  }

  Future<void> getNextPage() async {
    final currentState = state;

    if (currentState is! ReadPendingClientSuccess) return;

    if (_isLastPage) return;

    try {
      final clients = await clientRepository.getClientWithBalance(clientQueryParams);
      clientQueryParams.offset += clients.length;
      if (clients.length < clientQueryParams.limit) _isLastPage = true;
      emit(ReadPendingClientSuccess([...currentState.clients, ...clients]));
    } catch (error) {
      emit(ReadPendingClientError(error.toString()));
    }
  }
}
