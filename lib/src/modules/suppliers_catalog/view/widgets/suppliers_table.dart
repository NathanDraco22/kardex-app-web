import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/cubit/supplier_read_cubit.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/dialogs/create_supplier_dialog.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';
import 'package:kardex_app_front/widgets/status_tag_label.dart';

class SuppliersTable extends StatelessWidget {
  const SuppliersTable({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadSupplierCubit>();
    final state = cubit.state as ReadSupplierSuccess;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.3,
                  child: SearchFieldDebounced(
                    onSearch: (value) => cubit.searchSupplierByKeyword(value),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<ReadSupplierCubit, ReadSupplierState>(
            builder: (context, state) {
              if (state is! ReadSupplierSearching) return const SizedBox();
              return const LinearProgressIndicator();
            },
          ),

          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Text("Nombre"),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Telefono"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Text("Email"),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: Center(child: Text("Estado")),
                ),

                Flexible(
                  fit: FlexFit.tight,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          const Divider(),

          Builder(
            builder: (context) {
              if (state.suppliers.isEmpty) {
                return const Center(
                  child: NoItemWidget(
                    icon: Icons.warehouse,
                    text: "No hay proveedores",
                  ),
                );
              }

              return const _InnerRows();
            },
          ),
        ],
      ),
    );
  }
}

class _InnerRows extends StatelessWidget {
  const _InnerRows();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadSupplierCubit>();
    final state = cubit.state as ReadSupplierSuccess;
    final suppliers = state.suppliers;
    return Expanded(
      child: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final currentSupplier = suppliers[index];

          Color rowColor = index.isOdd ? Colors.white : Colors.grey.shade200;

          if (state is HighlightedSupplier) {
            if (state.updatedSuppliers.any((element) => element.id == currentSupplier.id)) {
              rowColor = Colors.blue.shade100;
            } else if (state.newSuppliers.any((element) => element.id == currentSupplier.id)) {
              rowColor = Colors.yellow.shade200;
            }
          }

          return _RowWidget(
            color: rowColor,
            supplier: currentSupplier,
          );
        },
      ),
    );
  }
}

class _RowWidget extends StatelessWidget {
  const _RowWidget({required this.color, required this.supplier});

  final Color color;
  final SupplierInDb supplier;

  @override
  Widget build(BuildContext context) {
    return Ink(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 2,
              child: Text(supplier.name),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(supplier.phone ?? "--"),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(supplier.email ?? "--"),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Center(
                child: Builder(
                  builder: (context) {
                    if (supplier.isActive) {
                      return const StatusTagLabel(
                        label: "Activo",
                        isActive: true,
                      );
                    } else {
                      return const StatusTagLabel(
                        label: "Inactivo",
                        isActive: false,
                      );
                    }
                  },
                ),
              ),
            ),

            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () async {
                    final res = await showCreateSupplierDialog(context, supplier: supplier);

                    if (res == null) return;
                    if (!context.mounted) return;
                    await context.read<ReadSupplierCubit>().markSupplierUpdated(res);
                    if (!context.mounted) return;
                    context.read<ReadSupplierCubit>().refreshSupplier();
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
