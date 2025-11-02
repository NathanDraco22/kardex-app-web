import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/query_params/devolution_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_devolution_state.dart';

class ReadDevolutionCubit extends Cubit<ReadDevolutionState> {
  ReadDevolutionCubit({required this.devolutionsRepository}) : super(ReadDevolutionInitial());

  final DevolutionsRepository devolutionsRepository;
  List<DevolutionInDb> _devolutionsCache = [];

  Future<void> loadAllDevolutions() async {
    emit(ReadDevolutionLoading());
    try {
      final devolutions = await devolutionsRepository.getAllDevolutions(DevolutionQueryParams());
      _devolutionsCache = devolutions;
      if (isClosed) return;
      emit(ReadDevolutionSuccess(devolutions));
    } catch (error) {
      if (isClosed) return;
      emit(ReadDevolutionError(error.toString()));
    }
  }

  void searchDevolution(String keyword) {
    if (keyword.isEmpty) {
      emit(ReadDevolutionSuccess(_devolutionsCache));
      return;
    }
    final filteredList = _devolutionsCache.where((devolution) {
      return devolution.clientInfo.name.toLowerCase().contains(keyword.toLowerCase()) ||
          devolution.docNumber.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
    emit(ReadDevolutionSuccess(filteredList));
  }

  Future<void> putDevolutionFirst(DevolutionInDb devolution) async {
    _devolutionsCache = [devolution, ..._devolutionsCache];
    final currentState = state;
    if (currentState is! ReadDevolutionSuccess) return;

    if (currentState is HighlightedDevolution) {
      emit(
        HighlightedDevolution(
          _devolutionsCache,
          newDevolutions: [devolution, ...currentState.newDevolutions],
          updatedDevolutions: currentState.updatedDevolutions,
        ),
      );
    } else {
      emit(HighlightedDevolution(_devolutionsCache, newDevolutions: [devolution]));
    }
  }

  Future<void> markDevolutionUpdated(DevolutionInDb devolution) async {
    final index = _devolutionsCache.indexWhere((d) => d.id == devolution.id);
    if (index != -1) _devolutionsCache[index] = devolution;

    final currentState = state;
    if (currentState is! ReadDevolutionSuccess) return;

    if (currentState is HighlightedDevolution) {
      emit(
        HighlightedDevolution(
          _devolutionsCache,
          newDevolutions: currentState.newDevolutions,
          updatedDevolutions: [devolution, ...currentState.updatedDevolutions],
        ),
      );
    } else {
      emit(HighlightedDevolution(_devolutionsCache, updatedDevolutions: [devolution]));
    }
  }

  Future<void> removeDevolution(DevolutionInDb devolution) async {
    _devolutionsCache.removeWhere((d) => d.id == devolution.id);
    emit(ReadDevolutionSuccess(_devolutionsCache));
  }
}
