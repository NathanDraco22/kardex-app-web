import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/web/current_proforma_web_screen.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';

class CurrentProformaScreen extends StatelessWidget {
  const CurrentProformaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    final (isSeller, currentUser) = RoleTools.isSeller();

    if (currentUser == null) {
      return const Center(child: Text("No Autorizado"));
    }

    return BlocProvider(
      create: (context) {
        final cubit = ReadProformaCubit(ordersRepository: orderRepo);
        if (isSeller) {
          cubit.setFilterParams(createdBy: currentUser.id);
        }
        return cubit..loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
      },
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cotizaciones/Proformas")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const CurrentProformaWebScreen();
  }
}
