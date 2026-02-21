import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client_group/client_group_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_client_group_state.dart';

class ReadClientGroupCubit extends Cubit<ReadClientGroupState> {
  ReadClientGroupCubit(this.clientGroupsRepository) : super(ReadClientGroupInitial());

  final ClientGroupsRepository clientGroupsRepository;

  Future<void> loadAllClientGroups() async {
    emit(ReadClientGroupLoading());
    try {
      final groups = await clientGroupsRepository.getAllClientGroups();
      emit(ReadClientGroupSuccess(groups));
    } catch (error) {
      emit(ClientGroupReadError(error.toString()));
    }
  }

  Future<void> searchClientGroupByKeywordLocal(String keyword) async {
    if (keyword.isEmpty) {
      emit(ReadClientGroupSuccess(clientGroupsRepository.clientGroups));
      return;
    }

    // Nota: Replicando lógica de Units que usa búsqueda local para filtros rápidos
    final groups = await clientGroupsRepository.searchClientGroupByKeywordLocal(keyword);
    emit(ReadClientGroupSuccess(groups));
  }

  Future<void> putGroupFirst(ClientGroupInDb group) async {
    final currentState = state as ReadClientGroupSuccess;
    final freshList = clientGroupsRepository.clientGroups;

    if (currentState is HighlightedClientGroup) {
      emit(
        HighlightedClientGroup(
          freshList,
          newGroups: [group, ...currentState.newGroups],
          updatedGroups: currentState.updatedGroups,
        ),
      );
      return;
    }
    emit(
      HighlightedClientGroup(
        freshList,
        newGroups: [group],
      ),
    );
  }

  Future<void> markGroupUpdated(ClientGroupInDb group) async {
    final currentState = state as ReadClientGroupSuccess;
    final freshList = clientGroupsRepository.clientGroups;

    if (currentState is HighlightedClientGroup) {
      emit(
        HighlightedClientGroup(
          freshList,
          newGroups: currentState.newGroups,
          updatedGroups: [group, ...currentState.updatedGroups],
        ),
      );
      return;
    }
    emit(
      HighlightedClientGroup(
        freshList,
        updatedGroups: [group],
      ),
    );
  }

  Future<void> refreshGroups() async {
    final currentState = state as ReadClientGroupSuccess;
    final freshList = clientGroupsRepository.clientGroups;

    if (currentState is HighlightedClientGroup) {
      emit(
        HighlightedClientGroup(
          freshList,
          newGroups: currentState.newGroups,
          updatedGroups: currentState.updatedGroups,
        ),
      );
      return;
    }
    emit(
      HighlightedClientGroup(
        freshList,
      ),
    );
  }
}
