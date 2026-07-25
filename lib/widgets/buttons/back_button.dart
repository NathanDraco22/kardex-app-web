import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/buttons/ctrl_key_tip.dart';

class BackIconButton extends StatelessWidget {
  const BackIconButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      Navigator.maybePop(context);
    }

    return CtrlKeyTip(
      hotKey: "ESC",
      onShortcut: onPressed,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.arrow_back,
        ),
      ),
    );
  }
}
