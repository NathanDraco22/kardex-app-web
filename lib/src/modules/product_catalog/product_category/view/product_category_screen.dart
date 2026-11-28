import 'dart:developer';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/product_category_cubit/read_product_category_cubit.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';

import '../dialogs/create_product_category_dialog.dart';
import 'widgets/product_category_table.dart';

part 'web/product_category_web.dart';
part 'mobile/product_category_mobile.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReadProductCategoryCubit>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return const _BaseScaffold();
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
