import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/current_orders_web_screen.dart';

class CurrentOrdersScreen extends StatelessWidget {
  const CurrentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();

    return BlocProvider(
      create: (context) => ReadOrderCubit(
        ordersRepository: orderRepo,
      )..loadPaginatedOrders(),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ordenes de Compra")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const CurrentOrdersWebScreen();
  }
}
