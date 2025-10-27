import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/expiration_log/expiration_log.dart';
import 'package:kardex_app_front/src/domain/query_params/expiration_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExpirationLogsRepository {
  final ExpirationLogsDataSource expirationLogsDataSource;

  ExpirationLogsRepository(this.expirationLogsDataSource);

  Future<ExpirationLogInDb> createExpirationLog(CreateExpirationLog createLog) async {
    final result = await expirationLogsDataSource.createExpirationLog(createLog.toJson());
    return ExpirationLogInDb.fromJson(result);
  }

  Future<List<ExpirationLogInDb>> getAllExpirationLogs(ExpirationQueryParams params) async {
    final results = await expirationLogsDataSource.getAllExpirationLogs(
      params.toMap(),
    );
    final response = ListResponse<ExpirationLogInDb>.fromJson(
      results,
      ExpirationLogInDb.fromJson,
    );
    return response.data;
  }

  Future<ExpirationLogInDb?> getExpirationLogById(String logId) async {
    final result = await expirationLogsDataSource.getExpirationLogById(logId);
    if (result == null) return null;
    return ExpirationLogInDb.fromJson(result);
  }

  Future<ExpirationLogInDb?> deleteExpirationLogById(String logId) async {
    final result = await expirationLogsDataSource.deleteExpirationLogById(logId);
    if (result == null) return null;
    return ExpirationLogInDb.fromJson(result);
  }

  Future<bool> hasExpiration(String branchId) async {
    final result = await expirationLogsDataSource.hasNearExpiration(branchId);
    return result;
  }
}
