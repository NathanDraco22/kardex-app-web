import 'package:kardex_business/src/data/credit_note_data_source.dart';
import 'package:kardex_business/src/domain/models/credit_note/credit_note.dart';
import 'package:kardex_business/src/domain/query_params/credit_note_query_params.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';
import 'package:kardex_business/src/tools/reactive_repo/reactive_repository.dart';

class CreditNotesRepository with ReactiveRepository<CreditNoteInDb> {
  final CreditNotesDataSource creditNotesDataSource;

  CreditNotesRepository(this.creditNotesDataSource);

  Future<CreditNoteInDb> createCreditNote(CreateCreditNote createCreditNote) async {
    final result = await creditNotesDataSource.createCreditNote(createCreditNote.toJson());
    final newItem = CreditNoteInDb.fromJson(result);
    notifyItemCreated(newItem);
    return newItem;
  }

  Future<List<CreditNoteInDb>> getAllCreditNotes(CreditNoteQueryParams params) async {
    final results = await creditNotesDataSource.getAllCreditNotes(params.toMap());
    final response = ListResponse<CreditNoteInDb>.fromJson(results, CreditNoteInDb.fromJson);
    return response.data;
  }

  Future<List<CreditNoteInDb>> getAllActiveCreditNotes(CreditNoteQueryParams params) async {
    final results = await creditNotesDataSource.getAllActiveCreditNotes(params.toMap());
    final response = ListResponse<CreditNoteInDb>.fromJson(results, CreditNoteInDb.fromJson);
    return response.data;
  }

  Future<List<CreditNoteInDb>> getCreditNotesByClientId(
    String clientId, {
    CreditNoteStatus? status,
  }) async {
    final results = await creditNotesDataSource.getCreditNotesByClientId(
      clientId,
      status: status?.name,
    );
    final response = ListResponse<CreditNoteInDb>.fromJson(results, CreditNoteInDb.fromJson);
    return response.data;
  }

  Future<List<CreditNoteInDb>> getCreditNotesByInvoiceId(
    String invoiceId, {
    String? clientId,
  }) async {
    final results = await creditNotesDataSource.getCreditNotesByInvoiceId(
      invoiceId,
      clientId: clientId,
    );
    final response = ListResponse<CreditNoteInDb>.fromJson(results, CreditNoteInDb.fromJson);
    return response.data;
  }

  Future<CreditNoteInDb?> getCreditNoteById(String creditNoteId) async {
    final result = await creditNotesDataSource.getCreditNoteById(creditNoteId);
    if (result == null) return null;
    return CreditNoteInDb.fromJson(result);
  }

  Future<CreditNoteInDb?> getCreditNoteByDocNumber(String docNumber) async {
    final result = await creditNotesDataSource.getCreditNoteByDocNumber(docNumber);
    if (result == null) return null;
    return CreditNoteInDb.fromJson(result);
  }

  Future<CreditNoteInDb> deleteCreditNote(String creditNoteId) async {
    final result = await creditNotesDataSource.deleteCreditNote(creditNoteId);
    final deleted = CreditNoteInDb.fromJson(result);
    notifyItemDeleted(deleted);
    return deleted;
  }
}
