import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

import 'cubit/read_product_sale_profile_cubit.dart';
import 'cubit/write_product_sale_profile_cubit.dart';
import 'web/product_price_setting_web.dart';

class ProductPriceSettingScreen extends StatelessWidget {
  const ProductPriceSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileRepo = context.read<ProductSaleProfilesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return ReadProductSaleProfileCubit(
              profilesRepository: profileRepo,
            )..loadCurrentBranchProfiles();
          },
        ),
        BlocProvider(
          create: (context) => WriteProductSaleProfileCubit(
            profilesRepository: profileRepo,
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
        title: const Text("Configuracion de Precios de Productos"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ProductPriceSettingWeb();
  }
}
