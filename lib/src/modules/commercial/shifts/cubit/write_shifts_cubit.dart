import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'write_shifts_state.dart';

class WriteShiftsCubit extends Cubit<WriteShiftsState> {
  final ShiftsRepository shiftsRepository;

  WriteShiftsCubit({required this.shiftsRepository}) : super(WriteShiftsInitial());

  Future<ShiftInDb?> openShift(CreateShift request) async {
    emit(WriteShiftsLoading());
    try {
      final created = await shiftsRepository.createShift(request);
      if (isClosed) return created;
      emit(ShiftOpenedSuccess(created));
      return created;
    } catch (e) {
      if (isClosed) return null;
      emit(WriteShiftsError(e.toString()));
      return null;
    }
  }

  Future<ShiftPreview?> loadPreview(String shiftId) async {
    emit(WriteShiftsLoading());
    try {
      final preview = await shiftsRepository.getShiftPreview(shiftId);
      if (isClosed) return preview;
      emit(ShiftPreviewLoaded(preview));
      return preview;
    } catch (e) {
      if (isClosed) return null;
      emit(WriteShiftsError(e.toString()));
      return null;
    }
  }

  Future<ShiftInDb?> closeShift(String shiftId, CloseShiftRequest request) async {
    emit(WriteShiftsLoading());
    try {
      final closed = await shiftsRepository.closeShift(shiftId, request);
      if (isClosed) return closed;
      emit(ShiftClosedSuccess(closed));
      return closed;
    } catch (e) {
      if (isClosed) return null;
      emit(WriteShiftsError(e.toString()));
      return null;
    }
  }
}
