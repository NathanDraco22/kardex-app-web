import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/mobile/current_orders_mobile_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/current_orders_web_screen.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class CurrentOrdersScreen extends StatelessWidget {
  const CurrentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    final (isSeller, currentUser) = RoleTools.isSeller();

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No Autorizado')),
      );
    }

    return BlocProvider(
      create: (context) => ReadOrderCubit(
        ordersRepository: orderRepo,
        branchId: getIt<AuthCubit>().currentBranchId,
        defaultCreatorId: isSeller ? currentUser.id : null,
      )..loadPaginatedOrders(),
      child: const _ResponsiveView(),
    );
  }
}

class _ResponsiveView extends StatelessWidget {
  const _ResponsiveView();

  @override
  Widget build(BuildContext context) {
    if (context.isMobileOrTablet()) {
      return const CurrentOrdersMobileScreen();
    }
    return const CurrentOrdersWebScreen();
  }
}
