import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'write_unit_scale_state.dart';

class WriteUnitScaleCubit extends Cubit<WriteUnitScaleState> {
  WriteUnitScaleCubit(this.unitScalesRepository) : super(WriteUnitScaleInitial());

  final UnitScalesRepository unitScalesRepository;

  Future<UnitScaleInDb?> createNewUnitScale(CreateUnitScale createScale) async {
    emit(WriteUnitScaleInProgress());
    try {
      final scale = await unitScalesRepository.createUnitScale(createScale);
      emit(WriteUnitScaleSuccess(scale));
      emit(WriteUnitScaleInitial());
      return scale;
    } catch (error) {
      emit(WriteUnitScaleError(error.toString()));
      return null;
    }
  }

  Future<UnitScaleInDb?> updateUnitScale(String id, UpdateUnitScale updateScale) async {
    emit(WriteUnitScaleInProgress());
    try {
      final scale = await unitScalesRepository.updateUnitScaleById(id, updateScale);
      if (scale != null) {
        emit(WriteUnitScaleSuccess(scale));
      }
      emit(WriteUnitScaleInitial());
      return scale;
    } catch (error) {
      emit(WriteUnitScaleError(error.toString()));
      return null;
    }
  }

  Future<UnitScaleInDb?> deleteUnitScale(String id) async {
    emit(WriteUnitScaleInProgress());
    try {
      final scale = await unitScalesRepository.deleteUnitScaleById(id);
      if (scale != null) {
        emit(DeleteUnitScaleSuccess(scale));
      }
      emit(WriteUnitScaleInitial());
      return scale;
    } catch (error) {
      emit(WriteUnitScaleError(error.toString()));
      return null;
    }
  }
}
