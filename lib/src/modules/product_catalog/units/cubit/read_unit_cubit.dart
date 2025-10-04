import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/unit/unit_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_unit_state.dart';

class ReadUnitCubit extends Cubit<ReadUnitState> {
  ReadUnitCubit(this.unitsRepository) : super(ReadUnitInitial());

  final UnitsRepository unitsRepository;

  Future<void> loadAllUnits() async {
    emit(ReadUnitLoading());
    try {
      final units = await unitsRepository.getAllUnits();
      emit(ReadUnitSuccess(units));
    } catch (error) {
      emit(UnitReadError(error.toString()));
    }
  }

  Future<void> searchUnitByKeyword(String keyword) async {
    final currentState = state as ReadUnitSuccess;

    if (keyword.isEmpty) {
      emit(ReadUnitSuccess(unitsRepository.units));
      return;
    }

    emit(UnitReadSearching(currentState.units));
    try {
      final units = await unitsRepository.searchUnitByKeyword(keyword);
      emit(ReadUnitSuccess(units));
    } catch (error) {
      emit(UnitReadError(error.toString()));
    }
  }

  Future<void> putUnitFirst(UnitInDb unit) async {
    final currentState = state as ReadUnitSuccess;
    final freshList = unitsRepository.units;
    if (currentState is HighlightedUnit) {
      emit(
        HighlightedUnit(
          freshList,
          newUnits: [unit, ...currentState.newUnits],
          updatedUnits: currentState.updatedUnits,
        ),
      );
      return;
    }
    emit(
      HighlightedUnit(
        freshList,
        newUnits: [unit],
      ),
    );
  }

  Future<void> markUnitUpdated(UnitInDb unit) async {
    final currentState = state as ReadUnitSuccess;
    final freshList = unitsRepository.units;

    if (currentState is HighlightedUnit) {
      emit(
        HighlightedUnit(
          freshList,
          newUnits: currentState.newUnits,
          updatedUnits: [unit, ...currentState.updatedUnits],
        ),
      );
      return;
    }
    emit(
      HighlightedUnit(
        freshList,
        updatedUnits: [unit],
      ),
    );
  }

  Future<void> refreshUnit() async {
    final currentState = state as ReadUnitSuccess;
    final freshList = unitsRepository.units;
    if (currentState is HighlightedUnit) {
      emit(
        HighlightedUnit(
          freshList,
          newUnits: currentState.newUnits,
          updatedUnits: currentState.updatedUnits,
        ),
      );
      return;
    }
    emit(
      HighlightedUnit(
        freshList,
      ),
    );
  }
}
