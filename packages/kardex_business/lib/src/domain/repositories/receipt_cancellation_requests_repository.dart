import 'package:kardex_business/src/data/receipt_cancellation_requests_data_source.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/models/receipt_cancellation_request/receipt_cancellation_request_model.dart';
import 'package:kardex_business/src/domain/query_params/receipt_cancellation_request_query_params.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class ReceiptCancellationRequestsRepository
    with ReactiveRepository<ReceiptCancellationRequestInDb> {
  final ReceiptCancellationRequestsDataSource dataSource;

  ReceiptCancellationRequestsRepository(this.dataSource);

  Future<ReceiptCancellationRequestInDb> createRequest(
    CreateReceiptCancellationRequest request,
  ) async {
    final result = await dataSource.createRequest(request.toJson());
    final item = ReceiptCancellationRequestInDb.fromJson(result);
    notifyItemCreated(item);
    return item;
  }

  Future<List<ReceiptCancellationRequestInDb>> getAllRequests(
    ReceiptCancellationRequestQueryParams params,
  ) async {
    final result = await dataSource.getAllRequests(params.toMap());
    final response = ListResponse<ReceiptCancellationRequestInDb>.fromJson(
      result,
      ReceiptCancellationRequestInDb.fromJson,
    );
    return response.data;
  }

  Future<int> countPendingRequests({String? branchId}) async {
    final result = await dataSource.countPendingRequests(branchId: branchId);
    return (result['count'] as num?)?.toInt() ?? 0;
  }

  Future<ReceiptCancellationRequestInDb> getRequestById(String id) async {
    final result = await dataSource.getRequestById(id);
    return ReceiptCancellationRequestInDb.fromJson(result);
  }

  Future<ReceiptCancellationRequestInDb> approveRequest(
    String id,
    UserInfo reviewedBy, {
    String reviewNotes = '',
  }) async {
    final result = await dataSource.approveRequest(id, {
      'reviewedBy': reviewedBy.toJson(),
      'reviewNotes': reviewNotes,
    });
    final item = ReceiptCancellationRequestInDb.fromJson(result);
    notifyItemUpdated(item);
    return item;
  }

  Future<ReceiptCancellationRequestInDb> rejectRequest(
    String id,
    UserInfo reviewedBy, {
    required String reviewNotes,
  }) async {
    final result = await dataSource.rejectRequest(id, {
      'reviewedBy': reviewedBy.toJson(),
      'reviewNotes': reviewNotes,
    });
    final item = ReceiptCancellationRequestInDb.fromJson(result);
    notifyItemUpdated(item);
    return item;
  }

  Future<ReceiptCancellationRequestInDb> cancelRequest(
    String id,
    UserInfo cancelledBy,
  ) async {
    final result = await dataSource.cancelRequest(id, {
      'cancelledBy': cancelledBy.toJson(),
    });
    final item = ReceiptCancellationRequestInDb.fromJson(result);
    notifyItemUpdated(item);
    return item;
  }
}
