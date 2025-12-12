import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/web/current_proforma_web_screen.dart';

class CurrentProformaScreen extends StatelessWidget {
  const CurrentProformaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();

    return BlocProvider(
      create: (context) => ReadProformaCubit(
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
      appBar: AppBar(title: const Text("Cotizaciones/Proformas")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const CurrentProformaWebScreen();
  }
}
