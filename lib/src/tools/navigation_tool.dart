import 'package:kardex_business/kardex_business.dart';

class NavigationTool {
  static String getNavigationAuthenticatedDestination(Servin servin, UserInDb user) {
    if (!servin.isMultiBranch) {
      return "home";
    }

    final multiBranchRoles = ["Admin"];

    if (multiBranchRoles.contains(user.role)) {
      return "multibranch-home";
    }

    return "home";
  }
}
