import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/write_product_cubit.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../cubit/read_product_cubit.dart';

part 'form_section.dart';
part 'widgets.dart';

Future<ProductInDb?> showCreateProductDialog(
  BuildContext context, {
  ProductInDb? product,
}) async {
  final writeCubit = context.read<WriteProductCubit>();
  final readCubit = context.read<ReadProductCubit>();

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
        BlocProvider.value(value: readCubit),
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
          context.read<ReadProductCubit>().removeProduct(state.product);
          await DialogManager.showInfoDialog(context, "Se ha borrado el producto ${state.product.name}");
          if (!context.mounted) return;
          context.pop(state.product);
        }

        if (state is WriteProductError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
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
