import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';

class BranchesTool {
  static BranchInDb? _currentBranch;
  static List<BranchInDb> _branches = [];
  static String _currentBranchId = kOriginBranchId;

  static List<BranchInDb> get branches => _branches;

  static String getCurrentBranchName() => _currentBranch?.name ?? "No Branch Selected";

  static String getCurrentBranchId() => _currentBranch?.id ?? _currentBranchId;

  static BranchInDb? getCurrentBranch() => _currentBranch;

  static BranchInDb getBranchById(String branchId) => _branches.firstWhere((branch) => branch.id == branchId);

  static void setCurrentBranch(BranchInDb branch) {
    _currentBranch = branch;
    _currentBranchId = branch.id;
  }

  static void setBranches(List<BranchInDb> branches) {
    _branches = branches;
  }
}
