import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/cubit/write_product_price_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/price_to_product/dialog/create_product_price_dialog.dart';

import 'cubit/read_product_price_cubit.dart';

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
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    return const PriceToProductWeb();
  }
}
