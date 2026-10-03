import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class RoleTools {
  static (bool, UserInDb?) isSeller() {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) {
      return (false, null);
    }
    final role = authState.session.user.role;
    final isSellerRole = role == "Vendedor" || role == "Pre-Venta";
    return (isSellerRole, authState.session.user);
  }
}
