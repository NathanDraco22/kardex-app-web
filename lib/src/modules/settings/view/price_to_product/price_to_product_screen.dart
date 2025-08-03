import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/cubit/write_product_price_cubit.dart';

import 'cubit/read_product_price_cubit.dart';

part 'mobile/price_to_product_mobile.dart';
part 'web/price_to_product_web.dart';

class PriceToProductScreen extends StatelessWidget {
  const PriceToProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productPriceRepo = context.read<ProductPricesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadProductPriceCubit(productPriceRepo)..loadAllProductPrices()),
        BlocProvider(create: (context) => WriteProductPriceCubit(productPriceRepo)),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("PriceToProductScreen"),
    );
  }
}
