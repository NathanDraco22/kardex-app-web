import 'package:kardex_app_front/src/data/exit_doc_data_source.dart';
import 'package:kardex_app_front/src/domain/models/exit_doc/exit_doc_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExitDocsRepository {
  final ExitDocsDataSource exitDocsDataSource;

  ExitDocsRepository(this.exitDocsDataSource);

  List<ExitDocInDb> _exitDocs = [];

  List<ExitDocInDb> get exitDocs => _exitDocs;

  Future<ExitDocInDb> createExitDoc(CreateExitDoc createExitDoc) async {
    final result = await exitDocsDataSource.createExitDoc(createExitDoc.toJson());
    final newDoc = ExitDocInDb.fromJson(result);
    _exitDocs = [newDoc, ..._exitDocs];
    return newDoc;
  }

  Future<List<ExitDocInDb>> getAllExitDocs() async {
    final results = await exitDocsDataSource.getAllExitDocs();
    final response = ListResponse<ExitDocInDb>.fromJson(
      results,
      ExitDocInDb.fromJson,
    );

    _exitDocs = response.data;
    _exitDocs.sort((a, b) => b.docDate.compareTo(a.docDate));
    return _exitDocs;
  }

  Future<ExitDocInDb?> getExitDocById(String docId) async {
    final result = await exitDocsDataSource.getExitDocById(docId);
    if (result == null) return null;
    return ExitDocInDb.fromJson(result);
  }

  Future<List<ExitDocInDb>> searchExitDocByKeyword(String keyword) async {
    final result = await exitDocsDataSource.searchExitDocByKeyword(keyword);
    final response = ListResponse<ExitDocInDb>.fromJson(
      result,
      ExitDocInDb.fromJson,
    );
    return response.data;
  }
}
