import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';

class ShiftsGate extends StatelessWidget {
  const ShiftsGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      bloc: getIt<AppSettingsCubit>(),
      builder: (context, state) {
        final isVisible = getIt<AppSettingsCubit>().useShifts;
        if (!isVisible) return const SizedBox.shrink();
        return child;
      },
    );
  }
}
