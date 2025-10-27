import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expiration_log/expiration_log.dart';
import 'package:kardex_app_front/src/domain/query_params/expiration_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_expiration_log_state.dart';

class ReadExpirationLogCubit extends Cubit<ReadExpirationLogState> {
  ReadExpirationLogCubit({required this.expirationLogsRepository}) : super(ReadExpirationLogInitial());

  final ExpirationLogsRepository expirationLogsRepository;
  List<ExpirationLogInDb> _logsCache = [];

  Future<void> loadAllExpirationLogs() async {
    emit(ReadExpirationLogLoading());
    try {
      final params = ExpirationQueryParams(
        branchId: BranchesTool.getCurrentBranchId(),
      );
      final logs = await expirationLogsRepository.getAllExpirationLogs(
        params,
      );
      _logsCache = logs;
      if (isClosed) return;
      emit(ReadExpirationLogSuccess(logs));
    } catch (error) {
      if (isClosed) return;
      emit(ReadExpirationLogError(error.toString()));
    }
  }

  void searchLog(String keyword) {
    if (keyword.isEmpty) {
      emit(ReadExpirationLogSuccess(_logsCache));
      return;
    }
    final filteredList = _logsCache.where((log) {
      return log.product.name.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
    emit(ReadExpirationLogSuccess(filteredList));
  }

  Future<void> putLogFirst(ExpirationLogInDb log) async {
    _logsCache = [log, ..._logsCache];
    final currentState = state;
    if (currentState is! ReadExpirationLogSuccess) return;

    if (currentState is HighlightedExpirationLog) {
      emit(HighlightedExpirationLog(_logsCache, newLogs: [log, ...currentState.newLogs]));
    } else {
      emit(HighlightedExpirationLog(_logsCache, newLogs: [log]));
    }
  }

  Future<void> removeLog(ExpirationLogInDb log) async {
    _logsCache.removeWhere((l) => l.id == log.id);
    emit(ReadExpirationLogSuccess(_logsCache));
  }
}
