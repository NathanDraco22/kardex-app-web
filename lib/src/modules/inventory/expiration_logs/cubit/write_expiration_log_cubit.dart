import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expiration_log/expiration_log.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_expiration_log_state.dart';

class WriteExpirationLogCubit extends Cubit<WriteExpirationLogState> {
  WriteExpirationLogCubit({required this.expirationLogsRepository}) : super(WriteExpirationLogInitial());

  final ExpirationLogsRepository expirationLogsRepository;

  Future<void> createNewExpirationLog(CreateExpirationLog createLog) async {
    emit(WriteExpirationLogInProgress());
    try {
      final log = await expirationLogsRepository.createExpirationLog(createLog);
      emit(WriteExpirationLogSuccess(log));
      emit(WriteExpirationLogInitial());
    } catch (error) {
      emit(WriteExpirationLogError(error.toString()));
    }
  }

  Future<void> deleteExpirationLog(String logId) async {
    emit(WriteExpirationLogInProgress());
    try {
      final log = await expirationLogsRepository.deleteExpirationLogById(logId);
      emit(DeleteExpirationLogSuccess(log!));
      emit(WriteExpirationLogInitial());
    } catch (error) {
      emit(WriteExpirationLogError(error.toString()));
    }
  }
}
