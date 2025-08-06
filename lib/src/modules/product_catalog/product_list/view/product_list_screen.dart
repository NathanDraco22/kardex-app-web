import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/read_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/write_product_cubit.dart';
import 'package:kardex_app_front/src/tools/constant.dart';

part 'web/product_list_screen_web.dart';
part 'mobile/product_list_screen_mobile.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepo = context.read<ProductsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadProductCubit(productRepo)..loadAllProducts()),
        BlocProvider(create: (context) => WriteProductCubit(productRepo)),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    if (screenSize.width < maxPhoneScreenWidth) return const ProductListScreenMobile();
    return const ProductListScreenWeb();
  }
}
