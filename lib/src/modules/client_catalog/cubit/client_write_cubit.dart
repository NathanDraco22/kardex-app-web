import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'client_write_state.dart';

class ClientWriteCubit extends Cubit<ClientWriteState> {
  ClientWriteCubit(this.clientsRepository) : super(ClientWriteInitial());

  final ClientsRepository clientsRepository;

  Future<void> createNewClient(CreateClient createClient) async {
    emit(ClientWriteInProgress());
    try {
      final clients = await clientsRepository.createClient(createClient);
      emit(ClientWriteSuccess(clients));
      emit(ClientWriteInitial());
    } catch (error) {
      emit(ClientWriteError(error.toString()));
    }
  }

  Future<void> updateClient(String clientId, UpdateClient updateClient) async {
    emit(ClientWriteInProgress());
    try {
      final clients = await clientsRepository.updateClientById(clientId, updateClient);
      emit(ClientWriteSuccess(clients!));
      emit(ClientWriteInitial());
    } catch (error) {
      emit(ClientWriteError(error.toString()));
    }
  }

  Future<void> deleteClient(String clientId) async {
    emit(ClientWriteInProgress());
    try {
      final clients = await clientsRepository.deleteClientById(clientId);
      emit(ClientWriteSuccess(clients!));
      emit(ClientWriteInitial());
    } catch (error) {
      emit(ClientWriteError(error.toString()));
    }
  }
}
