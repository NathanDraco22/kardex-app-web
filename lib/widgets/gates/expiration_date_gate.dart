import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

class ExpirationDateGate extends StatelessWidget {
  const ExpirationDateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    return Visibility(
      visible: authState.servin.isUsingExpirationDate,
      child: child,
    );
  }
}
