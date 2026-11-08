import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_unit_scales_state.dart';

class ReadUnitScalesCubit extends Cubit<ReadUnitScalesState> {
  ReadUnitScalesCubit(this.unitScalesRepository) : super(ReadUnitScalesInitial());

  final UnitScalesRepository unitScalesRepository;

  Future<void> loadAllUnitScales() async {
    emit(ReadUnitScalesLoading());
    try {
      final scales = await unitScalesRepository.getAllUnitScales();
      emit(ReadUnitScalesSuccess(scales));
    } catch (error) {
      emit(ReadUnitScalesError(error.toString()));
    }
  }

  Future<void> searchUnitScales(String keyword) async {
    if (state is! ReadUnitScalesSuccess) return;

    if (keyword.isEmpty) {
      emit(ReadUnitScalesSuccess(unitScalesRepository.unitScales));
      return;
    }

    final filtered = await unitScalesRepository.searchUnitScaleByKeywordLocal(keyword);
    emit(ReadUnitScalesSuccess(filtered));
  }

  Future<void> refreshUnitScales() async {
    try {
      final scales = await unitScalesRepository.getAllUnitScales();
      emit(ReadUnitScalesSuccess(scales));
    } catch (error) {
      emit(ReadUnitScalesError(error.toString()));
    }
  }
}
