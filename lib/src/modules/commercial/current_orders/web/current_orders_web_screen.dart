import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/cubit/read_order_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
// Requerido en lite donde widgets.dart no re-exporta CustomOrderListTile.
// ignore: unnecessary_import
import 'package:kardex_app_front/widgets/custom_order_list_tile.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class CurrentOrdersWebScreen extends StatelessWidget {
  const CurrentOrdersWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Compra'),
        actions: [
          BlocBuilder<ReadOrderCubit, ReadOrderState>(
            builder: (context, state) {
              final isLoading = state is ReadOrderLoading;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isLoading
                    ? null
                    : () => context.read<ReadOrderCubit>().loadPaginatedOrders(),
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
      body: const _Body(),
      bottomNavigationBar: const _WebBottomAppBar(),
    );
  }
}

class _WebBottomAppBar extends StatelessWidget {
  const _WebBottomAppBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadOrderCubit>().state;
    if (state is! ReadOrderSuccess) {
      return const SizedBox.shrink();
    }

    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TitleLabel(
            crossAxisAlignment: CrossAxisAlignment.center,
            title: 'Monto Total (${state.orders.length})',
            bigTitle: NumberFormatter.convertToMoneyLike(state.totalAmount),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
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
    );
  }
}
