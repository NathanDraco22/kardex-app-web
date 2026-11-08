import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';

class RootUserGate extends StatelessWidget {
  const RootUserGate({
    super.key,
    required this.child,
    this.fallback,
    this.width,
    this.height,
  });

  final Widget child;
  final Widget? fallback;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().user;
    final isRoot = user != null && user.id == 'root';

    final result = isRoot ? child : (fallback ?? const SizedBox.shrink());
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: result);
    }
    return result;
  }
}
