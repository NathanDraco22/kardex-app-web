import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_state.dart';

class ExpirationDateGate extends StatelessWidget {
  const ExpirationDateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    if (!authState.servin.isUsingExpirationDate) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      bloc: getIt<AppSettingsCubit>(),
      builder: (context, state) {
        final isVisible = getIt<AppSettingsCubit>().useExpirationDates;
        if (!isVisible) return const SizedBox.shrink();
        return child;
      },
    );
  }
}
