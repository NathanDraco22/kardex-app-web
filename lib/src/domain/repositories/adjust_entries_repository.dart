import 'package:kardex_app_front/src/data/adjust_entries_data_source.dart';
import 'package:kardex_app_front/src/domain/models/adjust_entry/adjust_entry_model.dart';
import 'package:kardex_app_front/src/domain/query_params/adjust_query_params.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class AdjustEntriesRepository {
  final AdjustEntriesDataSource dataSource;

  AdjustEntriesRepository(this.dataSource);

  Future<AdjustEntryInDb> createAdjustEntry(CreateAdjustEntry entry) async {
    final res = await dataSource.createAdjustEntry(entry.toJson());
    return AdjustEntryInDb.fromJson(res);
  }

  Future<List<AdjustEntryInDb>> getAllAdjustEntries(AdjustQueryParams queryParams) async {
    final res = await dataSource.getAllAdjustEntries(queryParams.toMap());
    final response = ListResponse<AdjustEntryInDb>.fromJson(res, AdjustEntryInDb.fromJson);
    return response.data;
  }

  Future<AdjustEntryInDb> getAdjustEntryById(String id) async {
    final res = await dataSource.getAdjustEntryById(id);
    return AdjustEntryInDb.fromJson(res);
  }

  Future<AdjustEntryInDb> getAdjustEntryByDocNumber(String docNumber, String branchId) async {
    final res = await dataSource.getAdjustEntryByDocNumber(docNumber, branchId);
    return AdjustEntryInDb.fromJson(res);
  }
}
