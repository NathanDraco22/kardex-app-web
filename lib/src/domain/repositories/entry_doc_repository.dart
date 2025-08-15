import 'package:kardex_app_front/src/data/entry_doc_data_source.dart';
import 'package:kardex_app_front/src/domain/models/entry_doc/entry_doc_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class EntryDocsRepository {
  final EntryDocsDataSource entryDocsDataSource;

  EntryDocsRepository(this.entryDocsDataSource);

  List<EntryDocInDb> _entryDocs = [];

  List<EntryDocInDb> get entryDocs => _entryDocs;

  Future<EntryDocInDb> createEntryDoc(CreateEntryDoc createEntryDoc) async {
    final result = await entryDocsDataSource.createEntryDoc(createEntryDoc.toJson());
    final newDoc = EntryDocInDb.fromJson(result);
    _entryDocs = [newDoc, ..._entryDocs];
    return newDoc;
  }

  Future<List<EntryDocInDb>> getAllEntryDocs() async {
    final results = await entryDocsDataSource.getAllEntryDocs();
    final response = ListResponse<EntryDocInDb>.fromJson(
      results,
      EntryDocInDb.fromJson,
    );

    _entryDocs = response.data;
    // Ordena por fecha de documento, de más reciente a más antiguo
    _entryDocs.sort((a, b) => b.docDate.compareTo(a.docDate));
    return _entryDocs;
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
