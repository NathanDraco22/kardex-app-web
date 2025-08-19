import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/exit_doc/exit_doc_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class ExitDocsRepository {
  final ExitDocsDataSource exitDocsDataSource;

  ExitDocsRepository(this.exitDocsDataSource);

  Future<ExitDocInDb> createExitDoc(CreateExitDoc createExitDoc) async {
    final result = await exitDocsDataSource.createExitDoc(createExitDoc.toJson());
    final newDoc = ExitDocInDb.fromJson(result);
    return newDoc;
  }

  Future<List<ExitDocInDb>> getPaginatedExitDocs(int offset) async {
    final results = await exitDocsDataSource.getPaginatedExitDocs(offset);
    final response = ListResponse<ExitDocInDb>.fromJson(
      results,
      ExitDocInDb.fromJson,
    );
    return response.data;
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
