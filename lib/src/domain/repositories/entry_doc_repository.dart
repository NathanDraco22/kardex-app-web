import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/entry_doc/entry_doc_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class EntryDocsRepository {
  final EntryDocsDataSource entryDocsDataSource;

  EntryDocsRepository(this.entryDocsDataSource);

  Future<EntryDocInDb> createEntryDoc(CreateEntryDoc createEntryDoc) async {
    final result = await entryDocsDataSource.createEntryDoc(createEntryDoc.toJson());
    final newDoc = EntryDocInDb.fromJson(result);
    return newDoc;
  }

  Future<List<EntryDocInDb>> getPaginatedEntryDocs(int offset) async {
    final results = await entryDocsDataSource.getPaginatedEntryDocs(offset);
    final response = ListResponse<EntryDocInDb>.fromJson(
      results,
      EntryDocInDb.fromJson,
    );
    return response.data;
  }

  Future<EntryDocInDb?> getEntryDocById(String docId) async {
    final result = await entryDocsDataSource.getEntryDocById(docId);
    if (result == null) return null;
    return EntryDocInDb.fromJson(result);
  }

  Future<List<EntryDocInDb>> searchEntryDocByKeyword(String keyword) async {
    final result = await entryDocsDataSource.searchEntryDocByKeyword(keyword);
    final response = ListResponse<EntryDocInDb>.fromJson(
      result,
      EntryDocInDb.fromJson,
    );
    return response.data;
  }
}
