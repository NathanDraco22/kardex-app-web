import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/product_demand_vs_stock/web/product_demand_vs_stock_screen_web.dart';

import 'cubit/read_product_stock_demand_cubit.dart';

class ProductDemandVsStockScreen extends StatelessWidget {
  const ProductDemandVsStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    return BlocProvider(
      create: (context) => ReadProductStockDemandCubit(
        ordersRepository: orderRepo,
      )..loadProductStockDemand(getIt<AuthCubit>().currentBranchId),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cotizaciones vs Existencias")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ProductDemandVsStockScreenWeb();
  }
}
