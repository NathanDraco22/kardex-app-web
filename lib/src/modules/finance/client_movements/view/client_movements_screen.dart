import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/client_transaction/read_client_transaction_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/client_transaction_repository.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

import 'mobile/client_movements_screen_mobile.dart';

class ClientMovementsScreen extends StatelessWidget {
  const ClientMovementsScreen({super.key, this.initialClient});

  final ClientInDb? initialClient;

  @override
  Widget build(BuildContext context) {
    final clientTransRepo = context.read<ClientTransactionsRepository>();
    return BlocProvider(
      create: (context) => ReadClientTransactionCubit(
        transactionsRepository: clientTransRepo,
      ),
      child: _RootScaffold(initialClient: initialClient),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold({this.initialClient});

  final ClientInDb? initialClient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Body(initialClient: initialClient),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({this.initialClient});

  final ClientInDb? initialClient;

  @override
  Widget build(BuildContext context) {
    // For now, we use the mobile layout for everything as Web is not yet implemented
    // and we want to verify functionality.
    // In strict mirroring, we would check context.isMobile().
    final isMobile = context.isMobile();

    // Fallback to mobile for now even on web (or show placeholder)
    if (isMobile) return ClientMovementsScreenMobile(initialClient: initialClient);

    // Reusing mobile for web temporarily to ensure functionality is testable on desktop too if needed
    return ClientMovementsScreenMobile(initialClient: initialClient);
  }
}
