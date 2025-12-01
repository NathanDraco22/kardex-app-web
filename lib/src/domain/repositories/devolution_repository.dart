import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/devolution/devolution.dart';
import 'package:kardex_app_front/src/domain/query_params/devolution_query_params.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

class DevolutionsRepository {
  final DevolutionsDataSource devolutionsDataSource;

  DevolutionsRepository(this.devolutionsDataSource);

  Future<DevolutionInDb> createDevolution(CreateDevolution createDevolution) async {
    final result = await devolutionsDataSource.createDevolution(createDevolution.toJson());
    return DevolutionInDb.fromJson(result);
  }

  Future<List<DevolutionInDb>> getAllDevolutions(DevolutionQueryParams params) async {
    final results = await devolutionsDataSource.getAllDevolutions(params.toMap());
    final response = ListResponse<DevolutionInDb>.fromJson(results, DevolutionInDb.fromJson);
    return response.data;
  }

  Future<List<DevolutionInDb>> getConfirmedDevolutions(String userId) async {
    final params = DevolutionQueryParams()
      ..branchId = BranchesTool.getCurrentBranchId()
      ..status = DevolutionStatus.confirmed
      ..clientId = userId;

    final results = await devolutionsDataSource.getAllDevolutions(params.toMap());
    final response = ListResponse<DevolutionInDb>.fromJson(results, DevolutionInDb.fromJson);
    return response.data;
  }

  Future<List<DevolutionInDb>> getOpenDevolutions(String userId) async {
    final params = DevolutionQueryParams()
      ..branchId = BranchesTool.getCurrentBranchId()
      ..status = DevolutionStatus.open
      ..clientId = userId;

    final results = await devolutionsDataSource.getAllDevolutions(params.toMap());
    final response = ListResponse<DevolutionInDb>.fromJson(results, DevolutionInDb.fromJson);
    return response.data;
  }

  Future<DevolutionInDb?> getDevolutionById(
    String devolutionId,
  ) async {
    final result = await devolutionsDataSource.getDevolutionById(devolutionId);
    if (result == null) return null;
    return DevolutionInDb.fromJson(result);
  }

  Future<DevolutionInDb?> confirmDevolutionById(String devolutionId) async {
    final result = await devolutionsDataSource.confirmDevolutionById(devolutionId);
    if (result == null) return null;
    return DevolutionInDb.fromJson(result);
  }

  Future<DevolutionInDb?> confirmAnonDevolutionById(String devolutionId) async {
    final result = await devolutionsDataSource.confirmAnonDevolutionById(devolutionId);
    if (result == null) return null;
    return DevolutionInDb.fromJson(result);
  }

  Future<DevolutionInDb?> cancelDevolutionById(String devolutionId) async {
    final result = await devolutionsDataSource.cancelDevolutionById(devolutionId);
    if (result == null) return null;
    return DevolutionInDb.fromJson(result);
  }

  Future<DevolutionInDb?> deleteDevolutionById(String devolutionId) async {
    final result = await devolutionsDataSource.deleteDevolutionById(devolutionId);
    if (result == null) return null;
    return DevolutionInDb.fromJson(result);
  }

  Future<List<DevolutionInDb>> getDevolutionHistory(InvoiceQueryParams params) async {
    final results = await devolutionsDataSource.getDevolutionHistory(params.toMap());
    final response = ListResponse<DevolutionInDb>.fromJson(results, DevolutionInDb.fromJson);
    return response.data;
  }

  Future<DevolutionInDb> getDevolutionByDocNumber(String docNumber) async {
    final result = await devolutionsDataSource.getDevolutionByDocNumber(docNumber);
    return DevolutionInDb.fromJson(result);
  }
}
