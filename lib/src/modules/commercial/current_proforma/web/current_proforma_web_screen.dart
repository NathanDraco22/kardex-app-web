import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/cubit/read_proforma_cubit.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
// Requerido en lite donde widgets.dart no re-exporta CustomOrderListTile.
// ignore: unnecessary_import
import 'package:kardex_app_front/widgets/custom_order_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

import 'invoice_creator/invoice_creator_screen.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class CurrentProformaWebScreen extends StatelessWidget {
  const CurrentProformaWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        actions: [
          BlocBuilder<ReadProformaCubit, ReadProformaState>(
            builder: (context, state) {
              final isLoading = state is ReadProformaLoading;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<ReadProformaCubit>()
                        .loadPaginatedOrders(getIt<AuthCubit>().currentBranchId),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(),
              SizedBox(height: 8),
              Expanded(child: _ContentSection()),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openCreateProforma(BuildContext context) async {
  await context.pushNamed(RouteNames.proforma);
  if (!context.mounted) return;
  await context.read<ReadProformaCubit>().loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
}
