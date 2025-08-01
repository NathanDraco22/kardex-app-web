import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/cubit/supplier_read_cubit.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/cubit/supplier_write_cubit.dart';

import '../dialogs/create_supplier_dialog.dart';
import '../widgets/suppliers_table.dart';

class SuppliersCatalogScreen extends StatelessWidget {
  const SuppliersCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supplierRepo = context.read<SuppliersRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadSupplierCubit(supplierRepo)..loadAllSuppliers(),
        ),
        BlocProvider(create: (context) => SupplierWriteCubit(supplierRepo)),
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
      appBar: AppBar(title: const Text("Lista de Proveedores")),
      body: BlocBuilder<ReadSupplierCubit, ReadSupplierState>(
        builder: (context, state) {
          if (state is ReadSupplierLoading || state is ReadSupplierInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SupplierReadError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const _Body();
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await showCreateSupplierDialog(context);
                      if (res == null) return;
                      if (!context.mounted) return;
                      await context.read<ReadSupplierCubit>().putSupplierFirst(res);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Agregar Nuevo Proveedor"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Expanded(
              child: SuppliersTable(),
            ),
          ],
        ),
      ),
    );
  }
}
