import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/transfers/write_transfer_cubit.dart';

import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';
import 'package:kardex_app_front/src/modules/inventory/create_transfer/mediator.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
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

    return NotificationListener<RebuildTransferScreenNotification>(
      onNotification: (notification) {
        notifier = CreateTransferNotifier();
        rebuildScreen = true;
        setState(() {});
        return true;
      },
      child: BlocProvider(
        create: (context) => WriteTransferCubit(repository: transferRepo),
        child: CreateTransferMediator(
          notifier: notifier,
          child: const _RootScaffold(),
        ),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

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
