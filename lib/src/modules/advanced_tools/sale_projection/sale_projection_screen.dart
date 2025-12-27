import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/product_stats_repository.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/sale_projection/cubits/read_sale_projection_cubit.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/sale_projection/web/sale_projection_screen_web.dart';

import 'cubits/export_excel_cubit.dart';

class SaleProjectionScreen extends StatelessWidget {
  const SaleProjectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productStatRepo = context.read<ProductStatsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadSaleProjectionCubit(
            productStatsRepository: productStatRepo,
          ),
        ),
        BlocProvider(
          create: (context) => ExportExcelCubit(
            productStatsRepository: productStatRepo,
          ),
        ),
      ],
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const SaleProjectionScreenWeb();
  }
}
