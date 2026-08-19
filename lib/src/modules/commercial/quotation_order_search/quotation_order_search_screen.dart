import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/quotation_order_search/cubit/read_quotation_order_search_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/quotation_order_search/web/quotation_order_search_screen_web.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';

class QuotationOrderSearchScreen extends StatelessWidget {
  const QuotationOrderSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadQuotationOrderSearchCubit(
            ordersRepository: orderRepo,
            defaultCreatorId: isSellerRole ? userInDb?.id : null,
          )..loadDocuments(getIt<AuthCubit>().currentBranchId),
        ),
        BlocProvider(
          create: (context) => ReadProformaCubit(ordersRepository: orderRepo),
        ),
        BlocProvider(
          create: (context) => ReadOrderCubit(ordersRepository: orderRepo),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final scrollOffset = notification.metrics.pixels;
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        if (scrollOffset >= maxScrollExtent * 0.65) {
          context
              .read<ReadQuotationOrderSearchCubit>()
              .nextPage(getIt<AuthCubit>().currentBranchId);
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Buscador de Cotizaciones/Órdenes")),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const QuotationOrderSearchScreenWeb();
  }
}