import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/read_product_in_branch/read_product_in_branch_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/product_price_catalog/web/product_catalog_web.dart';
import 'package:kardex_app_front/src/modules/inventory/product_price_catalog/cubits/export_price_list_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
class ProductPriceCatalogScreen extends StatelessWidget {
  const ProductPriceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsRepo = context.read<ProductsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return ReadProductInBranchCubit(
              productsRepository: productsRepo,
            )..getProducts();
          },
        ),
        BlocProvider(
          create: (context) => ExportPriceListCubit(),
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
        title: const Text("Catálogo de Precios"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return BlocProvider.value(
                    value: context.read<ExportPriceListCubit>(),
                    child: AlertDialog(
                      title: const Text("Exportar Catálogo"),
                      content: const Text("¿Deseas exportar el catálogo de precios actual a Excel?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancelar"),
                        ),
                        BlocConsumer<ExportPriceListCubit, ExportPriceListState>(
                          listener: (context, state) {
                            if (state is ExportPriceListFailure) {
                              DialogManager.showErrorDialog(context, state.message);
                            }
                            if (state is ExportPriceListSuccess) {
                              Navigator.pop(dialogContext);
                            }
                          },
                          builder: (context, state) {
                            if (state is ExportPriceListLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            return ElevatedButton.icon(
                              onPressed: () {
                                context.read<ExportPriceListCubit>().exportExcel();
                              },
                              icon: const Icon(Icons.file_download),
                              label: const Text("Exportar a Excel"),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.file_download),
            tooltip: "Exportar a Excel",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ProductCatalogWeb();
  }
}
