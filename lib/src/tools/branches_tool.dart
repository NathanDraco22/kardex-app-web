import 'package:kardex_app_front/constants/default_values.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';

class BranchesTool {
  static BranchInDb? _currentBranch;
  static String _currentBranchId = kOriginBranchId;

  static String getCurrentBranchName() => _currentBranch?.name ?? "No Branch Selected";

  static String getCurrentBranchId() => _currentBranch?.id ?? _currentBranchId;

  static void setCurrentBranch(BranchInDb branch) {
    _currentBranch = branch;
    _currentBranchId = branch.id;
  }
}
