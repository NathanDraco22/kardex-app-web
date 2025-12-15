import 'package:kardex_app_front/src/domain/models/servin/servin.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';

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
