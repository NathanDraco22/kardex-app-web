import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_unit_state.dart';

class WriteUnitCubit extends Cubit<WriteUnitState> {
  WriteUnitCubit(this.unitsRepository) : super(WriteUnitInitial());

  final UnitsRepository unitsRepository;

  Future<void> createNewUnit(CreateUnit createUnit) async {
    emit(WriteUnitInProgress());
    try {
      final unit = await unitsRepository.createUnit(createUnit);
      emit(WriteUnitSuccess(unit));
      emit(WriteUnitInitial());
    } catch (error) {
      emit(WriteUnitError(error.toString()));
    }
  }

  Future<void> updateUnit(String unitId, UpdateUnit updateUnit) async {
    emit(WriteUnitInProgress());
    try {
      final unit = await unitsRepository.updateUnitById(unitId, updateUnit);
      emit(WriteUnitSuccess(unit!));
      emit(WriteUnitInitial());
    } catch (error) {
      emit(WriteUnitError(error.toString()));
    }
  }

  Future<void> deleteUnit(String unitId) async {
    emit(WriteUnitInProgress());
    try {
      final unit = await unitsRepository.deleteUnitById(unitId);
      emit(DeleteUnitSuccess(unit!));
      emit(WriteUnitInitial());
    } catch (error) {
      emit(WriteUnitError(error.toString()));
    }
  }
}
