import 'package:kardex_business/src/data/invoice_cancellation_requests_data_source.dart';
import 'package:kardex_business/src/domain/models/common/user_info.dart';
import 'package:kardex_business/src/domain/models/invoice_cancellation_request/invoice_cancellation_request_model.dart';
import 'package:kardex_business/src/domain/query_params/invoice_cancellation_request_query_params.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class InvoiceCancellationRequestsRepository
    with ReactiveRepository<InvoiceCancellationRequestInDb> {
  final InvoiceCancellationRequestsDataSource dataSource;

  InvoiceCancellationRequestsRepository(this.dataSource);

  Future<InvoiceCancellationRequestInDb> createRequest(
    CreateInvoiceCancellationRequest request,
  ) async {
    final result = await dataSource.createRequest(request.toJson());
    final item = InvoiceCancellationRequestInDb.fromJson(result);
    notifyItemCreated(item);
    return item;
  }

  Future<List<InvoiceCancellationRequestInDb>> getAllRequests(
    InvoiceCancellationRequestQueryParams params,
  ) async {
    final result = await dataSource.getAllRequests(params.toMap());
    final response = ListResponse<InvoiceCancellationRequestInDb>.fromJson(
      result,
      InvoiceCancellationRequestInDb.fromJson,
    );
    return response.data;
  }

  Future<int> countPendingRequests({String? branchId}) async {
    final result = await dataSource.countPendingRequests(branchId: branchId);
    return (result['count'] as num?)?.toInt() ?? 0;
  }

  Future<InvoiceCancellationRequestInDb> getRequestById(String id) async {
    final result = await dataSource.getRequestById(id);
    return InvoiceCancellationRequestInDb.fromJson(result);
  }

  Future<InvoiceCancellationRequestInDb> approveRequest(
    String id,
    UserInfo reviewedBy, {
    String reviewNotes = '',
  }) async {
    final result = await dataSource.approveRequest(id, {
      'reviewedBy': reviewedBy.toJson(),
      'reviewNotes': reviewNotes,
    });
    final item = InvoiceCancellationRequestInDb.fromJson(result);
    notifyItemUpdated(item);
    return item;
  }

  Future<InvoiceCancellationRequestInDb> rejectRequest(
    String id,
    UserInfo reviewedBy, {
    required String reviewNotes,
  }) async {
    final result = await dataSource.rejectRequest(id, {
      'reviewedBy': reviewedBy.toJson(),
      'reviewNotes': reviewNotes,
    });
    final item = InvoiceCancellationRequestInDb.fromJson(result);
    notifyItemUpdated(item);
    return item;
  }

  Future<InvoiceCancellationRequestInDb> cancelRequest(
    String id,
    UserInfo cancelledBy,
  ) async {
    final result = await dataSource.cancelRequest(id, {
      'cancelledBy': cancelledBy.toJson(),
    });
    final item = InvoiceCancellationRequestInDb.fromJson(result);
    notifyItemUpdated(item);
    return item;
  }
}
