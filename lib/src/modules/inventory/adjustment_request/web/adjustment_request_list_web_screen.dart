import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/read_adjustment_requests_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_list_tile.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

part 'sections/list_header_section.dart';
part 'sections/list_content_section.dart';

class AdjustmentRequestListWebScreen extends StatelessWidget {
  const AdjustmentRequestListWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de Ajuste'),
        actions: [
          BlocBuilder<ReadAdjustmentRequestsCubit, ReadAdjustmentRequestsState>(
            builder: (context, state) {
              final isRefreshing = state is ReadAdjustmentRequestsSuccess && state.isRefreshing;
              return IconButton(
                tooltip: 'Actualizar',
                onPressed: isRefreshing ? null : () => context.read<ReadAdjustmentRequestsCubit>().refresh(),
                icon: isRefreshing
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
              _ListHeaderSection(),
              SizedBox(height: 8),
              Expanded(child: _ListContentSection()),
            ],
          ),
        ),
      ),
    );
  }
}
