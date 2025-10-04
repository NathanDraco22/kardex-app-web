import 'package:kardex_app_front/constants/default_values.dart';

class BranchesTool {
  static String _currentBranchId = kOriginBranchId;

  static String getCurrentBranchId() => _currentBranchId;

  static void setCurrentBranchId(String branchId) => _currentBranchId = branchId;
}
