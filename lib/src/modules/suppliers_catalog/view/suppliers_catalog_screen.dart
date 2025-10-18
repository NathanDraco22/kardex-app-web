import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/cubit/supplier_read_cubit.dart';
import 'package:kardex_app_front/src/modules/suppliers_catalog/cubit/supplier_write_cubit.dart';
import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/row_widgets/mobile_row.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import '../dialogs/create_supplier_dialog.dart';
import 'widgets/suppliers_table.dart';

part 'web/supplier_catalog_web.dart';
part 'mobile/supplier_catalog_mobile.dart';

class SuppliersCatalogScreen extends StatelessWidget {
  const SuppliersCatalogScreen({super.key});

  static const accessName = Modules.suppliers;

  @override
  Widget build(BuildContext context) {
    final supplierRepo = context.read<SuppliersRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadSupplierCubit(supplierRepo)..loadAllSuppliers(),
        ),
        BlocProvider(create: (context) => WriteSupplierCubit(supplierRepo)),
      ],
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    final screenSized = MediaQuery.sizeOf(context);

    if (screenSized.width < maxPhoneScreenWidth) return const SupplierCatalogMobile();
    return const SuppliersCatalogWeb();
  }
}
