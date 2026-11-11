import 'package:kardex_business/src/data/adjustment_requests_data_source.dart';
import 'package:kardex_business/src/domain/models/adjustment_request/adjustment_request_model.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/query_params/adjustment_request_query_params.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class AdjustmentRequestsRepository with ReactiveRepository<AdjustmentRequestInDb> {
  final AdjustmentRequestsDataSource dataSource;

  AdjustmentRequestsRepository(this.dataSource);

  Future<AdjustmentRequestInDb> createAdjustmentRequest(CreateAdjustmentRequest request) async {
    final result = await dataSource.createAdjustmentRequest(request.toJson());
    final newItem = AdjustmentRequestInDb.fromJson(result);
    notifyItemCreated(newItem);
    return newItem;
  }

  Future<List<AdjustmentRequestInDb>> getAllAdjustmentRequests(AdjustmentRequestQueryParams params) async {
    final result = await dataSource.getAllAdjustmentRequests(params.toMap());
    final response = ListResponse<AdjustmentRequestInDb>.fromJson(result, AdjustmentRequestInDb.fromJson);
    return response.data;
  }

  Future<AdjustmentRequestInDb> getAdjustmentRequestById(String id) async {
    final result = await dataSource.getAdjustmentRequestById(id);
    return AdjustmentRequestInDb.fromJson(result);
  }

  Future<AdjustmentRequestInDb> updateAdjustmentRequest(String id, UpdateAdjustmentRequest request) async {
    final result = await dataSource.updateAdjustmentRequestById(id, request.toJson());
    final updatedItem = AdjustmentRequestInDb.fromJson(result);
    notifyItemUpdated(updatedItem);
    return updatedItem;
  }

  Future<AdjustmentRequestInDb> deleteAdjustmentRequest(String id) async {
    final result = await dataSource.deleteAdjustmentRequestById(id);
    final deletedItem = AdjustmentRequestInDb.fromJson(result);
    notifyItemDeleted(deletedItem);
    return deletedItem;
  }

  Future<AdjustmentRequestInDb> approveAdjustmentRequest(String id, UserInfo approvedBy) async {
    final result = await dataSource.approveAdjustmentRequest(id, {'approvedBy': approvedBy.toJson()});
    final approvedItem = AdjustmentRequestInDb.fromJson(result);
    notifyItemUpdated(approvedItem);
    return approvedItem;
  }

  Future<AdjustmentRequestInDb> cancelAdjustmentRequest(String id, UserInfo cancelledBy, {String? reason}) async {
    final result = await dataSource.cancelAdjustmentRequest(id, {
      'cancelledBy': cancelledBy.toJson(),
      'reason': reason,
    });
    final cancelledItem = AdjustmentRequestInDb.fromJson(result);
    notifyItemUpdated(cancelledItem);
    return cancelledItem;
  }
}
