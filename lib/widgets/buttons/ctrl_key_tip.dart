import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kardex_app_front/widgets/shorcut_container.dart';

class CtrlKeyTip extends StatefulWidget {
  const CtrlKeyTip({
    super.key,
    required this.child,
    required this.hotKey,
    required this.onShortcut,
  });
  final Widget child;
  final String hotKey;
  final void Function() onShortcut;

  @override
  State<CtrlKeyTip> createState() => _CtrlKeyTipState();
}

class _CtrlKeyTipState extends State<CtrlKeyTip> {
  bool ctrlPressed = false;

  bool _handleKeyEvent(KeyEvent event) {
    ctrlPressed = HardwareKeyboard.instance.isControlPressed;

    setState(() => {});
    return false;
  }

  @override
  void initState() {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    RegisShortcutNotification(
      callback: widget.onShortcut,
      hotKey: widget.hotKey,
    ).dispatch(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (ctrlPressed)
          Positioned(
            bottom: -1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 3),
                ],
              ),
              child: Text(
                'CTRL + ${widget.hotKey}',
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
