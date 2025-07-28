import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';

part 'client_catalog_state.dart';

class ClientCatalogCubit extends Cubit<ClientCatalogState> {
  ClientCatalogCubit(this.clientsRepository) : super(ClientCatalogInitial());

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
}
