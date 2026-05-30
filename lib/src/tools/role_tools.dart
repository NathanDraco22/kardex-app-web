import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';

class RoleTools {
  static (bool, UserInDb?) isSeller() {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) {
      return (false, null);
    }
    return (authState.session.user.role == "Vendedor", authState.session.user);
  }
}
