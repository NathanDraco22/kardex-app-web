import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/cubit/read_client_group_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/cubit/write_client_group_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/dialog/client_group_form_dialog.dart';

part 'web/client_groups_screen_web.dart';

class ClientGroupsScreen extends StatelessWidget {
  const ClientGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientGroupsRepo = context.read<ClientGroupsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadClientGroupCubit(clientGroupsRepo)..loadAllClientGroups(),
        ),
        BlocProvider(
          create: (context) => WriteClientGroupCubit(clientGroupsRepo),
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
    return const ClientGroupsScreenWeb();
  }
}
