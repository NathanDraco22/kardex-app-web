import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class CreditNotesDataSource with HttpService {
  CreditNotesDataSource._();
  static final CreditNotesDataSource instance = CreditNotesDataSource._();
  factory CreditNotesDataSource() {
    return instance;
  }

  final _endpoint = "/credit-notes";

  Future<Map<String, dynamic>> createCreditNote(Map<String, dynamic> creditNote) async {
    final uri = HttpTools.generateUri(_endpoint);
    final headers = HttpTools.generateAuthHeaders();
    return await postQuery(uri, creditNote, headers: headers);
  }

  Future<Map<String, dynamic>> getAllCreditNotes(Map<String, String> params) async {
    final uri = HttpTools.generateUri(_endpoint, queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> getAllActiveCreditNotes(Map<String, String> params) async {
    final uri = HttpTools.generateUri("$_endpoint/all/active", queryParameters: params);
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> getCreditNotesByClientId(
    String clientId, {
    String? status,
  }) async {
    final queryParams = status != null ? {'status': status} : null;
    final uri = HttpTools.generateUri(
      "$_endpoint/client/$clientId",
      queryParameters: queryParams,
    );
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>> getCreditNotesByInvoiceId(
    String invoiceId, {
    String? clientId,
  }) async {
    final queryParams = clientId != null ? {'client_id': clientId} : null;
    final uri = HttpTools.generateUri(
      "$_endpoint/invoice/$invoiceId",
      queryParameters: queryParams,
    );
    final headers = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: headers);
  }

  Future<Map<String, dynamic>?> getCreditNoteById(String creditNoteId) async {
    final uri = HttpTools.generateUri("$_endpoint/$creditNoteId");
    final header = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>?> getCreditNoteByDocNumber(String docNumber) async {
    final uri = HttpTools.generateUri("$_endpoint/doc/$docNumber");
    final header = HttpTools.generateAuthHeaders();
    return await getQuery(uri, headers: header);
  }

  Future<Map<String, dynamic>> deleteCreditNote(String creditNoteId) async {
    final uri = HttpTools.generateUri("$_endpoint/$creditNoteId");
    final header = HttpTools.generateAuthHeaders();
    return await deleteQuery(uri, headers: header);
  }
}
