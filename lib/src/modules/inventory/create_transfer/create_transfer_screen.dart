import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/core/transfer_draft_manager.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/modules/inventory/create_transfer/mediator.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'mobile/create_transfer_screen_mobile.dart';
import 'web/create_transfer_screen_web.dart';

class CreateTransferScreen extends StatefulWidget {
  const CreateTransferScreen({super.key});

  @override
  State<CreateTransferScreen> createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen> {
  late CreateTransferNotifier notifier;
  bool rebuildScreen = false;

  @override
  void initState() {
    notifier = CreateTransferNotifier();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadDraft();
    });
  }

  Future<void> _checkAndLoadDraft() async {
    try {
      final branchId = getIt<AuthCubit>().currentBranchId;
      final draftManager = TransferDraftManager();
      final hasDraft = await draftManager.hasDraft(branchId);
      if (!hasDraft) return;

      if (!mounted) return;

      final reanudar = await DialogManager.showRestoreDraftDialog(context);

      if (reanudar == true) {
        final draft = await draftManager.getDraft(branchId);
        if (draft != null && mounted) {
          setState(() {
            notifier = CreateTransferNotifier(
              initialRows: draft.rows,
              destinationBranch: draft.destinationBranch,
              observations: draft.observations,
            );
          });
        }
      } else {
        await draftManager.clearDraft(branchId);
      }
    } catch (e, stack) {
      debugPrint("Error loading transfer draft: $e");
      debugPrint(stack.toString());
    }
  }

  Future<void> _handleExit(BuildContext context) async {
    final hasDestination = notifier.headerData.destinationBranch != null;
    final hasObservations = notifier.headerData.observations != null && notifier.headerData.observations!.isNotEmpty;
    final hasProducts = notifier.controller.rows.isNotEmpty;

    final hasData = hasDestination || hasObservations || hasProducts;

    if (!hasData) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final option = await DialogManager.showSaveDraftDialog(context);

    final branchId = getIt<AuthCubit>().currentBranchId;

    if (option == 1) {
      final draft = TransferDraft(
        destinationBranch: notifier.headerData.destinationBranch,
        observations: notifier.headerData.observations,
        rows: notifier.controller.rows,
      );
      await TransferDraftManager().saveDraft(branchId, draft);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else if (option == 2) {
      await TransferDraftManager().clearDraft(branchId);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rebuildScreen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        rebuildScreen = false;
        setState(() {});
      });
      return const EmptyScaffold();
    }

    final transferRepo = context.read<TransfersRepository>();

    return ShortcutContainer(
      child: NotificationListener<RebuildTransferScreenNotification>(
        onNotification: (notification) {
          final branchId = getIt<AuthCubit>().currentBranchId;
          TransferDraftManager().clearDraft(branchId);
          notifier = CreateTransferNotifier();
          rebuildScreen = true;
          setState(() {});
          return true;
        },
        child: BlocProvider(
          create: (context) => WriteTransferCubit(repository: transferRepo),
          child: CreateTransferMediator(
            notifier: notifier,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                await _handleExit(context);
              },
              child: _RootScaffold(key: ObjectKey(notifier)),
            ),
          ),
        ),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootBody();
  }
}

class _RootBody extends StatelessWidget {
  const _RootBody();

  @override
  Widget build(BuildContext context) {
    if (context.isMobile()) {
      return const CreateTransferScreenMobile();
    }
    return const CreateTransferScreenWeb();
  }
}
