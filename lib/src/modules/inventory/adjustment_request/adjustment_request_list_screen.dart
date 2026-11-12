import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/read_adjustment_requests_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/mobile/adjustment_request_list_mobile_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/web/adjustment_request_list_web_screen.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestListScreen extends StatelessWidget {
  const AdjustmentRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AdjustmentRequestsRepository>();
    final branchId = getIt<AuthCubit>().currentBranchId;
    final (isSeller, sellerUser) = RoleTools.isSeller();

    return BlocProvider(
      create: (_) => ReadAdjustmentRequestsCubit(
        repository: repository,
        branchId: branchId,
        defaultCreatorId: isSeller ? sellerUser?.id : null,
      )..loadFirstPage(),
      child: context.isMobileOrTablet()
          ? const AdjustmentRequestListMobileScreen()
          : const AdjustmentRequestListWebScreen(),
    );
  }
}
