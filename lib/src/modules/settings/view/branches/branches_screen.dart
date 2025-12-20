import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/settings/view/branches/dialog/create_branch_dialog.dart';

import 'cubit/read_branch_cubit.dart';
import 'cubit/write_branch_cubit.dart';

part 'web/branches_screen_web.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branchRepo = context.read<BranchesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadBranchCubit(branchRepo)..loadAllBranches()),
        BlocProvider(create: (context) => WriteBranchCubit(branchRepo)),
      ],
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    return const _BranchesScreenWeb();
  }
}
