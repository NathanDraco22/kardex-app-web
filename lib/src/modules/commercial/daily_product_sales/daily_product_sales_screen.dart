import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_sales/web/daily_product_sales_screen_web.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';

import 'cubit/read_daily_product_sales_cubit.dart';

class DailyProductSalesScreen extends StatelessWidget {
  const DailyProductSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();
    final (isSellerRole, userInDb) = RoleTools.isSeller(context);
    return BlocProvider(
      create: (context) =>
          ReadDailyProductSalesCubit(
            invoicesRepository: invoiceRepo,
            defaultCreatorId: isSellerRole ? userInDb?.id : null,
          )..loadDailyProductSales(
            startDate: DateTimeTool.getTodayMidnight(),
          ),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ventas Diarias por Producto")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const DailyProductSalesScreenWeb();
  }
}
