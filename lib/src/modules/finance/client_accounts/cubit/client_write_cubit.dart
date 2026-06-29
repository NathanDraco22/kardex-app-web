import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'client_write_state.dart';

class WriteClientCubit extends Cubit<WriteClientState> {
  WriteClientCubit(this.clientsRepository) : super(WriteClientInitial());

  final ClientsRepository clientsRepository;

  Future<void> createNewClient(CreateClient createClient) async {
    emit(WriteClientInProgress());
    try {
      final clients = await clientsRepository.createClient(createClient);
      emit(WriteClientSuccess(clients));
      emit(WriteClientInitial());
    } catch (error) {
      emit(WriteClientError(error.toString()));
    }
  }

  Future<void> updateClient(String clientId, UpdateClient updateClient) async {
    emit(WriteClientInProgress());
    try {
      final clients = await clientsRepository.updateClientById(clientId, updateClient);
      emit(WriteClientSuccess(clients!));
      emit(WriteClientInitial());
    } catch (error) {
      emit(WriteClientError(error.toString()));
    }
  }

  Future<void> deleteClient(String clientId) async {
    emit(WriteClientInProgress());
    try {
      final clients = await clientsRepository.deleteClientById(clientId);
      emit(DeleteClientSuccess(clients!));
      emit(WriteClientInitial());
    } catch (error) {
      emit(WriteClientError(error.toString()));
    }
  }
}
