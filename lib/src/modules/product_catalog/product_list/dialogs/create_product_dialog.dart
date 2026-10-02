import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:kardex_app_front/src/tools/uploaders/image_uploader.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/write_product_cubit.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

import '../cubit/read_product_cubit.dart';

part 'form_section.dart';
part 'widgets.dart';
part 'extra_units_section.dart';


Future<ProductInDb?> showCreateProductDialog(
  BuildContext context, {
  ProductInDb? product,
  WriteProductCubit? writeProductCubit,
  ReadProductCubit? readProductCubit,
}) async {
  final writeCubit = writeProductCubit ??
      (() {
        try {
          return context.read<WriteProductCubit>();
        } catch (_) {
          return WriteProductCubit(context.read<ProductsRepository>());
        }
      })();

  ReadProductCubit? readCubit = readProductCubit;
  if (readCubit == null) {
    try {
      readCubit = context.read<ReadProductCubit>();
    } catch (_) {
      readCubit = null;
    }
  }

  final productCateRepo = context.read<ProductCategoriesRepository>();
  final unitRepo = context.read<UnitsRepository>();

  final widget = MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: productCateRepo),
      RepositoryProvider.value(value: unitRepo),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider.value(value: writeCubit),
        if (readCubit != null) BlocProvider.value(value: readCubit),
      ],
      child: CreateProductDialog(product: product),
    ),
  );

  ProductInDb? result;

  if (context.isMobile()) {
    result = await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      builder: (context) {
        return widget;
      },
    );
  } else {
    result = await showDialog<ProductInDb?>(
      context: context,
      builder: (context) => widget,
    );
  }

  return result;
}

class CreateProductDialog extends StatefulWidget {
  const CreateProductDialog({super.key, this.product});

  final ProductInDb? product;

  @override
  State<CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<CreateProductDialog> {
  final formKey = GlobalKey<FormState>();
  final creationMap = {};

  @override
  Widget build(BuildContext context) {
    bool isActive = true;
    bool hasIva = false;

    if (widget.product != null) {
      isActive = widget.product!.isActive;
      hasIva = widget.product!.hasIva;
    }

    creationMap['isActive'] = isActive;
    creationMap['hasIva'] = hasIva;
    creationMap['altCode'] = widget.product?.altCode ?? "";

    final currentProduct = widget.product;

    return BlocListener<WriteProductCubit, WriteProductState>(
      listener: (context, state) async {
        if (state is WriteProductInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteProductSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.product);
        }

        if (state is WriteProductError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is DeleteProductSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          try {
            context.read<ReadProductCubit>().removeProduct(state.product);
          } catch (_) {}
          await DialogManager.showInfoDialog(context, "Se ha borrado el producto ${state.product.name}");
          if (!context.mounted) return;
          context.pop(state.product);
        }
      },
      child: Form(
        key: formKey,
        child: _FormContent(
          formKey: formKey,
          creationMap: creationMap,
          currentProduct: currentProduct,
        ),
      ),
    );
  }
}
