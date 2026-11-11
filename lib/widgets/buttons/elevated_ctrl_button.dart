import 'package:flutter/material.dart';

import 'ctrl_key_tip.dart';
import 'primary_menu_button.dart';

class ElevatedCtrlButton extends StatelessWidget {
  const ElevatedCtrlButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.hotKey,
    required this.icon,
    this.focusNode,
    this.autofocus = false,
  });

  final void Function()? onPressed;
  final String label;
  final String hotKey;
  final IconData icon;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return CtrlKeyTip(
      key: ValueKey(onPressed),
      hotKey: hotKey,
      onShortcut: onPressed ?? () {},
      child: PrimaryMenuButton(
        focusNode: focusNode,
        autofocus: autofocus,
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
