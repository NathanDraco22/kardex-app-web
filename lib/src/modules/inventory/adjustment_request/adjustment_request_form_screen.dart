import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/adjustment_request_mediator.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/cubit/write_adjustment_request_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/mobile/adjustment_request_form_mobile_screen.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/view_controller.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/web/adjustment_request_form_web_screen.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

class AdjustmentRequestFormScreen extends StatefulWidget {
  const AdjustmentRequestFormScreen({
    super.key,
    this.requestId,
    this.initialRequest,
  });

  final String? requestId;
  final AdjustmentRequestInDb? initialRequest;

  bool get isEditing => requestId != null || initialRequest != null;

  @override
  State<AdjustmentRequestFormScreen> createState() => _AdjustmentRequestFormScreenState();
}

class _AdjustmentRequestFormScreenState extends State<AdjustmentRequestFormScreen> {
  late final AdjustmentRequestViewController _viewController;

  AdjustmentRequestInDb? _editingRequest;
  bool _isLoadingInitial = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _viewController = AdjustmentRequestViewController();

    final request = widget.initialRequest;
    if (request != null) {
      _editingRequest = request;
    }

    if (widget.isEditing) {
      _isLoadingInitial = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
    }
  }

  @override
  void dispose() {
    _viewController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitial = true;
      _loadError = null;
    });

    try {
      final request =
          _editingRequest ??
          await context.read<AdjustmentRequestsRepository>().getAdjustmentRequestById(widget.requestId!);

      if (!mounted) return;

      if (request.status != AdjustmentRequestStatus.pending) {
        setState(() {
          _loadError = 'Solo las solicitudes pendientes pueden editarse.';
          _isLoadingInitial = false;
        });
        return;
      }

      final productIds = request.items.map((item) => item.productId).toSet().toList(growable: false);
      final products = productIds.isEmpty
          ? <ProductInDbInBranch>[]
          : await context.read<ProductsRepository>().getProductsInBranchByIds(
              branchId: request.branchId,
              request: GetProductsInBranchRequest(productIds: productIds),
            );

      if (!mounted) return;

      final allProductsLoaded = _viewController.prefill(request: request, products: products);

      setState(() {
        _editingRequest = request;
        _isLoadingInitial = false;
        _loadError = allProductsLoaded
            ? null
            : 'Algunos productos de la solicitud ya no están disponibles en la sucursal. '
                  'No es posible editarla sin perder información.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingInitial = false;
        _loadError = error.toString().replaceFirst('HttpServiceException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AdjustmentRequestsRepository>();

    return BlocProvider(
      create: (_) => WriteAdjustmentRequestCubit(repository: repository),
      child: AdjustmentRequestMediator(
        viewController: _viewController,
        child: _RootScaffold(
          isEditing: widget.isEditing,
          editingRequest: _editingRequest,
          isLoadingInitial: _isLoadingInitial,
          loadError: _loadError,
          onRetry: _loadInitialData,
        ),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({
    required this.isEditing,
    required this.editingRequest,
    required this.isLoadingInitial,
    required this.loadError,
    required this.onRetry,
  });

  final bool isEditing;
  final AdjustmentRequestInDb? editingRequest;
  final bool isLoadingInitial;
  final String? loadError;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteAdjustmentRequestCubit, WriteAdjustmentRequestState>(
      listener: (context, state) {
        switch (state) {
          case WritingAdjustmentRequest():
            LoadingDialogManager.showLoadingDialog(context);
          case AdjustmentRequestCreated():
            LoadingDialogManager.closeLoadingDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud de ajuste creada correctamente.')),
            );
            if (context.mounted) context.pop();
          case AdjustmentRequestUpdated():
            LoadingDialogManager.closeLoadingDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud de ajuste actualizada correctamente.')),
            );
            if (context.mounted) context.pop();
          case WriteAdjustmentRequestError(:final message):
            LoadingDialogManager.closeLoadingDialog(context);
            DialogManager.showErrorDialog(context, message);
          default:
            break;
        }
      },
      child: Builder(
        builder: (context) {
          if (isLoadingInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (loadError != null) {
            return Scaffold(
              appBar: AppBar(title: Text(isEditing ? 'Editar Solicitud de Ajuste' : 'Nueva Solicitud de Ajuste')),
              body: AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'No se pudo abrir la solicitud',
                subtitle: loadError,
                accentColor: AppThemeTokens.danger,
                actionLabel: 'Reintentar',
                actionIcon: Icons.refresh_rounded,
                onAction: onRetry,
              ),
            );
          }

          if (context.isMobileOrTablet()) {
            return AdjustmentRequestFormMobileScreen(
              editingRequest: editingRequest,
              isEditing: isEditing,
            );
          }

          return AdjustmentRequestFormWebScreen(
            editingRequest: editingRequest,
            isEditing: isEditing,
          );
        },
      ),
    );
  }
}
