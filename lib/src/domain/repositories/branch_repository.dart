import 'package:kardex_app_front/src/data/branche_data_source.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class BranchesRepository {
  final BranchesDataSource branchesDataSource;

  BranchesRepository(this.branchesDataSource);

  List<BranchInDb> _branches = [];

  List<BranchInDb> get branches => _branches;

  Future<BranchInDb> createBranch(CreateBranch createBranch) async {
    final result = await branchesDataSource.createBranch(createBranch.toJson());
    final newBranch = BranchInDb.fromJson(result);
    _branches = [..._branches, newBranch];
    return newBranch;
  }

  Future<List<BranchInDb>> getAllBranches() async {
    final results = await branchesDataSource.getAllBranches();
    final response = ListResponse<BranchInDb>.fromJson(
      results,
      BranchInDb.fromJson,
    );

    _branches = response.data;
    return _branches;
  }

  Future<BranchInDb?> getBranchById(String branchId) async {
    final result = await branchesDataSource.getBranchById(branchId);
    if (result == null) return null;
    return BranchInDb.fromJson(result);
  }

  Future<List<BranchInDb>> searchBranchByKeyword(String keyword) async {
    final result = await branchesDataSource.searchBranchByKeyword(keyword);
    final response = ListResponse<BranchInDb>.fromJson(
      result,
      BranchInDb.fromJson,
    );
    return response.data;
  }

  Future<BranchInDb?> updateBranchById(
    String branchId,
    UpdateBranch branch,
  ) async {
    final result = await branchesDataSource.updateBranchById(
      branchId,
      branch.toJson(),
    );
    if (result == null) return null;

    final updatedBranch = BranchInDb.fromJson(result);
    final index = _branches.indexWhere((b) => b.id == branchId);
    if (index != -1) {
      _branches[index] = updatedBranch;
    }
    return updatedBranch;
  }

  Future<BranchInDb?> deleteBranchById(String branchId) async {
    final result = await branchesDataSource.deleteBranchById(branchId);
    if (result == null) return null;

    final deletedBranch = BranchInDb.fromJson(result);
    _branches.removeWhere((b) => b.id == branchId);
    return deletedBranch;
  }
}
