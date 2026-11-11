import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/read_adjustment_request_detail_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/write_adjustment_request_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/mobile/adjustment_request_detail_mobile_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/web/adjustment_request_detail_web_screen.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestDetailScreen extends StatelessWidget {
  const AdjustmentRequestDetailScreen({
    super.key,
    required this.requestId,
    this.initialRequest,
  });

  final String requestId;
  final AdjustmentRequestInDb? initialRequest;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AdjustmentRequestsRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReadAdjustmentRequestDetailCubit(
            repository: repository,
            requestId: requestId,
          )..load(initialRequest: initialRequest),
        ),
        BlocProvider(
          create: (_) => WriteAdjustmentRequestCubit(repository: repository),
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
    return BlocListener<WriteAdjustmentRequestCubit, WriteAdjustmentRequestState>(
      listener: (context, state) {
        switch (state) {
          case WritingAdjustmentRequest():
            LoadingDialogManager.showLoadingDialog(context);
          case AdjustmentRequestApproved():
            LoadingDialogManager.closeLoadingDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud aprobada. Las existencias fueron actualizadas.')),
            );
          case AdjustmentRequestCancelled():
            LoadingDialogManager.closeLoadingDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud cancelada correctamente.')),
            );
          case WriteAdjustmentRequestError(:final message):
            LoadingDialogManager.closeLoadingDialog(context);
            DialogManager.showErrorDialog(context, message);
          default:
            break;
        }
      },
      child: BlocBuilder<ReadAdjustmentRequestDetailCubit, ReadAdjustmentRequestDetailState>(
        builder: (context, state) {
          switch (state) {
            case ReadAdjustmentRequestDetailInitial():
            case ReadAdjustmentRequestDetailLoading():
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case ReadAdjustmentRequestDetailError(:final message):
              return Scaffold(
                appBar: AppBar(title: const Text('Solicitud de Ajuste')),
                body: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'No se pudo cargar la solicitud',
                  subtitle: message,
                  accentColor: AppThemeTokens.danger,
                  actionLabel: 'Reintentar',
                  actionIcon: Icons.refresh_rounded,
                  onAction: () => context.read<ReadAdjustmentRequestDetailCubit>().refresh(),
                ),
              );
            case ReadAdjustmentRequestDetailSuccess(:final request):
              if (context.isMobileOrTablet()) {
                return AdjustmentRequestDetailMobileScreen(request: request);
              }
              return AdjustmentRequestDetailWebScreen(request: request);
          }
        },
      ),
    );
  }
}
