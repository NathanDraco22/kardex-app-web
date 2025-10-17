import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/app_theme.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>()..checkSession();
    return BlocListener(
      bloc: authCubit,
      listener: (context, state) async {
        if (state is AuthInactive) {
          context.goNamed("activation");
        }

        if (state is Authenticated) {
          context.goNamed("home");
        }

        if (state is Unauthenticated) {
          context.goNamed("login");
        }
      },
      child: const Scaffold(
        backgroundColor: ColourPalette.deepBackground,
        body: _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.watch<AuthCubit>();
    if (authCubit.state is AuthError) {
      final state = authCubit.state as AuthError;
      return Center(
        child: Text(
          state.message,
        ),
      );
    }
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
