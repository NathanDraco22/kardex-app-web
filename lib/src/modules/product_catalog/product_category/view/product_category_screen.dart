import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/cubit/read_product_category_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_category/cubit/write_product_category_cubit.dart';

import '../dialogs/create_product_category_dialog.dart';
import 'widgets/product_category_table.dart';

part 'web/product_category_web.dart';
part 'mobile/product_category_mobile.dart';

class ProductCategoryScreen extends StatelessWidget {
  const ProductCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productCateRepo = context.read<ProductCategoriesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadProductCategoryCubit(productCateRepo)..loadAllProductCategories(),
        ),
        BlocProvider(create: (context) => WriteProductCategoryCubit(productCateRepo)),
      ],
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    log(MediaQuery.sizeOf(context).width.toString());
    return const ProductCategoryWeb();
  }
}
