import 'package:kardex_app_front/src/data/adjust_exits_data_source.dart';
import 'package:kardex_app_front/src/domain/models/adjust_exit/adjust_exit_model.dart';
import 'package:kardex_app_front/src/domain/query_params/adjust_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class AdjustExitsRepository {
  final AdjustExitsDataSource dataSource;

  AdjustExitsRepository(this.dataSource);

  Future<AdjustExitInDb> createAdjustExit(CreateAdjustExit body) async {
    final res = await dataSource.createAdjustExit(body.toJson());
    return AdjustExitInDb.fromJson(res);
  }

  Future<List<AdjustExitInDb>> getAllAdjustExits(AdjustQueryParams query) async {
    final res = await dataSource.getAllAdjustExits(query.toMap());
    final response = ListResponse<AdjustExitInDb>.fromJson(res, AdjustExitInDb.fromJson);
    return response.data;
  }

  Future<AdjustExitInDb> getAdjustExitById(String id) async {
    final res = await dataSource.getAdjustExitById(id);
    return AdjustExitInDb.fromJson(res);
  }

  Future<AdjustExitInDb> getAdjustExitByDocNumber(String docNumber, String branchId) async {
    final res = await dataSource.getAdjustExitByDocNumber(docNumber, branchId);
    return AdjustExitInDb.fromJson(res);
  }
}
