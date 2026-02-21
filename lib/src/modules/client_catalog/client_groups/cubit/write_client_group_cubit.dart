import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client_group/client_group_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_client_group_state.dart';

class WriteClientGroupCubit extends Cubit<WriteClientGroupState> {
  WriteClientGroupCubit(this.clientGroupsRepository) : super(WriteClientGroupInitial());

  final ClientGroupsRepository clientGroupsRepository;

  Future<void> createNewGroup(CreateClientGroup createGroup) async {
    emit(WriteClientGroupInProgress());
    try {
      final group = await clientGroupsRepository.createClientGroup(createGroup);
      emit(WriteClientGroupSuccess(group));
      emit(WriteClientGroupInitial());
    } catch (error) {
      emit(WriteClientGroupError(error.toString()));
    }
  }

  Future<void> updateGroup(String groupId, UpdateClientGroup updateGroup) async {
    emit(WriteClientGroupInProgress());
    try {
      final group = await clientGroupsRepository.updateClientGroupById(groupId, updateGroup);
      emit(WriteClientGroupSuccess(group!));
      emit(WriteClientGroupInitial());
    } catch (error) {
      emit(WriteClientGroupError(error.toString()));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    emit(WriteClientGroupInProgress());
    try {
      final group = await clientGroupsRepository.deleteClientGroupById(groupId);
      emit(DeleteClientGroupSuccess(group!));
      emit(WriteClientGroupInitial());
    } catch (error) {
      emit(WriteClientGroupError(error.toString()));
    }
  }
}
