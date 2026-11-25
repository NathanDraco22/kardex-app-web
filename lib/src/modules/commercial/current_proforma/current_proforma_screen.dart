import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/mobile/current_proforma_mobile_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/web/current_proforma_web_screen.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_business/kardex_business.dart';

class CurrentProformaScreen extends StatelessWidget {
  const CurrentProformaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderRepo = context.read<OrdersRepository>();
    final (isSeller, currentUser) = RoleTools.isSeller();

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No Autorizado")),
      );
    }

    return BlocProvider(
      create: (context) {
        final cubit = ReadProformaCubit(
          ordersRepository: orderRepo,
          defaultCreatorId: isSeller ? currentUser.id : null,
        );
        return cubit..loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
      },
      child: const _ResponsiveView(),
    );
  }
}

class _ResponsiveView extends StatelessWidget {
  const _ResponsiveView();

  @override
  Widget build(BuildContext context) {
    if (context.isMobileOrTablet()) {
      return const CurrentProformaMobileScreen();
    }
    return const CurrentProformaWebScreen();
  }
}
