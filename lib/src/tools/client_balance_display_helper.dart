import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_business/kardex_business.dart';

/// Centraliza la visualización del saldo y límite de crédito del cliente
/// según la capacidad `showClientCreditDetails` del rol activo.
class ClientBalanceDisplayHelper {
  ClientBalanceDisplayHelper._();

  static const String pendingBalanceLabel = 'Con saldo pendiente';
  static const String noBalanceLabel = 'Sin saldo';

  static bool canShowDetails({
    AccessManager? accessManager,
    AuthCubit? authCubit,
  }) {
    final manager = accessManager ?? AccessManager();
    return manager.hasCurrentCapability(
      RoleCapability.showClientCreditDetails,
      authCubit: authCubit,
    );
  }

  static String formatBalance(int balance, {bool? showDetails}) {
    final canShow = showDetails ?? canShowDetails();
    if (canShow) {
      return NumberFormatter.convertToMoneyLike(balance);
    }
    return balance > 0 ? pendingBalanceLabel : noBalanceLabel;
  }

  static String formatCreditLimit(int creditLimit, {bool? showDetails}) {
    final canShow = showDetails ?? canShowDetails();
    if (canShow) {
      return NumberFormatter.convertToMoneyLike(creditLimit);
    }
    return 'Oculto';
  }
}
