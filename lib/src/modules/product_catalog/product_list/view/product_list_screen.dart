import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/read_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/write_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/dialogs/create_product_dialog.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/view/widgets/products_table.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/scroll_tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'web/product_list_screen_web.dart';
part 'mobile/product_list_screen_mobile.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productRepo = context.read<ProductsRepository>();
    final productCateRepo = context.read<ProductCategoriesRepository>();
    final unitRepo = context.read<UnitsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadProductCubit(
            productsRepository: productRepo,
            categoriesRepository: productCateRepo,
            unitsRepository: unitRepo,
          )..loadPaginatedProducts(),
        ),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final maxScrollExtends = notification.metrics.maxScrollExtent;
        final scrollOffset = notification.metrics.pixels;

        if (ScrollTools.calculateScrollPercent(maxScrollExtends, scrollOffset) > 70) {
          final cubit = context.read<ReadProductCubit>();
          cubit.getNextPagedProducts();
        }
        return true;
      },
      child: Builder(
        builder: (context) {
          if (context.isMobile()) return const ProductListScreenMobile();
          return const ProductListScreenWeb();
        },
      ),
    );
  }
}
