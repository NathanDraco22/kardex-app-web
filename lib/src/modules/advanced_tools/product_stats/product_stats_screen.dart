import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/product_stats/estimate_product_stats_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/product_stats_repository.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/product_stats/cubits/read_product_stats_cubit.dart';
import 'web/product_stats_web_screen.dart';

class ProductStatsScreen extends StatelessWidget {
  const ProductStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productStatRepo = context.read<ProductStatsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadProductStatsCubit(
            productStatsRepository: productStatRepo,
          ),
        ),
        BlocProvider(
          create: (context) => EstimateProductStatsCubit(
            productStatsRepository: productStatRepo,
          ),
        ),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimación de Productos por Ventas"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ProductStatsWeb();
  }
}
