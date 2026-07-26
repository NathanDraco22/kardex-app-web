import 'package:flutter/material.dart';

import 'ctrl_key_tip.dart';

class ElevatedCtrlButton extends StatelessWidget {
  const ElevatedCtrlButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.hotKey,
    required this.icon,
  });

  final void Function()? onPressed;
  final String label;
  final String hotKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CtrlKeyTip(
      key: ValueKey(onPressed),
      hotKey: hotKey,
      onShortcut: onPressed ?? () {},
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
