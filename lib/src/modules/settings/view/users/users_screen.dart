import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/settings/view/users/web/users_web_screen.dart';
import 'cubit/read_user_cubit.dart';
import 'cubit/write_user_cubit.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = context.read<UsersRepository>();
    final roleRepo = context.read<UserRolesRepository>();
    final branchRepo = context.read<BranchesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadUserCubit(
            usersRepository: userRepo,
            userRolesRepository: roleRepo,
            branchesRepository: branchRepo,
          )..loadPaginatedUsers(),
        ),
        BlocProvider(
          create: (context) => WriteUserCubit(
            usersRepository: userRepo,
          ),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const UsersWebScreen();
  }
}
