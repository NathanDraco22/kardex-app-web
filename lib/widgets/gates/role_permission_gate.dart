import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/core/access_manager.dart';

enum PermissionMode { whitelist, blacklist }

class RolePermissionGate extends StatelessWidget {
  const RolePermissionGate({
    super.key,
    required this.permissions,
    required this.child,
    this.mode = PermissionMode.whitelist,
    this.fallback,
    this.width,
    this.height,
  });

  final List<Enum> permissions;
  final Widget child;
  final PermissionMode mode;
  final Widget? fallback;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final accessManager = AccessManager();
    final hasAccess = switch (mode) {
      PermissionMode.whitelist => permissions.any(
        (p) => accessManager.hasCurrentAccess(context, p.name),
      ),
      PermissionMode.blacklist => permissions.every(
        (p) => !accessManager.hasCurrentAccess(context, p.name),
      ),
    };

    final result = hasAccess ? child : (fallback ?? const SizedBox.shrink());
    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: result);
    }
    return result;
  }
}
