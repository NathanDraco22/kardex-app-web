import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/cubit/read_devolution_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/mobile/current_devolutions_mobile_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_devolutions/web/current_devolutions_web_screen.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class CurrentDevolutionsScreen extends StatelessWidget {
  const CurrentDevolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devolutionRepo = context.read<DevolutionsRepository>();
    final branchId = getIt<AuthCubit>().currentBranchId;

    return BlocProvider(
      create: (context) => ReadDevolutionCubit(
        devolutionsRepository: devolutionRepo,
        branchId: branchId,
      )..loadAllDevolutions(),
      child: const _ResponsiveView(),
    );
  }
}

class _ResponsiveView extends StatelessWidget {
  const _ResponsiveView();

  @override
  Widget build(BuildContext context) {
    if (context.isMobileOrTablet()) {
      return const CurrentDevolutionsMobileScreen();
    }
    return const CurrentDevolutionsWebScreen();
  }
}
