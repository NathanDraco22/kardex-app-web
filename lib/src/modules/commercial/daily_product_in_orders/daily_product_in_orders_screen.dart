import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_in_orders/web/daily_product_in_orders_screen_web.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';

import 'cubit/read_daily_product_in_orders_cubit.dart';

class DailyProductInOrdersScreen extends StatelessWidget {
  const DailyProductInOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    return BlocProvider(
      create: (context) =>
          ReadDailyProductInOrdersCubit(
            ordersRepository: orderRepo,
            defaultCreatorId: isSellerRole ? userInDb?.id : null,
          )..loadDailyProductInOrders(
            branchId: getIt<AuthCubit>().currentBranchId,
            startDate: DateTimeTool.getTodayMidnight(),
          ),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Productos en Pedidos (Diario)")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const DailyProductInOrdersScreenWeb();
  }
}
