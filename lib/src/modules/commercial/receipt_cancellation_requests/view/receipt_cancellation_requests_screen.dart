import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/constants/route_names.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';
import 'package:kardex_app_front/src/tools/row_color_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/receipt_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

import '../cubit/read_receipt_cancellation_requests_cubit.dart';
import '../cubit/read_receipt_cancellation_requests_state.dart';
import '../cubit/write_receipt_cancellation_requests_cubit.dart';
import '../cubit/write_receipt_cancellation_requests_state.dart';

part 'sections/body_section.dart';
part 'sections/header_section.dart';

class ReceiptCancellationRequestsScreen extends StatelessWidget {
  const ReceiptCancellationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReceiptCancellationRequestsRepository>();
    final authState = getIt<AuthCubit>().state;
    final branchId = authState is Authenticated ? authState.branch.id : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadReceiptCancellationRequestsCubit(repo)
            ..loadRequests(branchId: branchId),
        ),
        BlocProvider(
          create: (_) => WriteReceiptCancellationRequestsCubit(repo),
        ),
      ],
      child: const _ReceiptCancellationRequestsView(),
    );
  }
}

class _ReceiptCancellationRequestsView extends StatelessWidget {
  const _ReceiptCancellationRequestsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteReceiptCancellationRequestsCubit,
        WriteReceiptCancellationRequestsState>(
      listener: (context, state) {
        if (state is WriteReceiptCancellationRequestsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is WriteReceiptCancellationRequestsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Solicitudes de Anulación de Recibos'),
          actions: [
            IconButton(
              tooltip: 'Recargar',
              onPressed: () {
                context
                    .read<ReadReceiptCancellationRequestsCubit>()
                    .loadRequests();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(),
              SizedBox(height: 4),
              Expanded(child: _BodySection()),
            ],
          ),
        ),
      ),
    );
  }
}
