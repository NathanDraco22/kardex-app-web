import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/product_movements/cubit/read_product_transaction_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/product_movements/view/web/commercial_product_movements_screen_web.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

import 'mobile/commercial_product_movements_screen_mobile.dart';

class CommercialProductMovementsScreen extends StatelessWidget {
  const CommercialProductMovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productTransRepo = context.read<ProductTransactionsRepository>();
    return BlocProvider(
      create: (context) => ReadProductTransactionCubit(
        transactionsRepository: productTransRepo,
      ),
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
    final isMobile = context.isMobile();

    if (isMobile) return const CommercialProductMovementsScreenMobile();

    return const CommercialProductMovementsScreenWeb();
  }
}
